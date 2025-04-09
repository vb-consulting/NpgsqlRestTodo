import { readdir } from "node:fs/promises";
import { CronJob } from "cron";
import cronstrue from "cronstrue";
import { addDbLog, colors, logSymbols, info, error } from "./log.js";
import SQL from './db.js';
import queuedWorker from "./_queuedWorker.js";

const formatTime = () => new Date().toISOString().replace('T', ' ').slice(0, 19);
const addDbInfo = async message => addDbLog({message, context: "worker"});
const formatDuration = (ms) => {
    if (ms < 1000) return `${ms}ms`;
    const seconds = Math.floor((ms / 1000) % 60);
    const minutes = Math.floor((ms / (1000 * 60)) % 60);
    const hours = Math.floor((ms / (1000 * 60 * 60)) % 24);
    const formatted = [
        hours > 0 ? `${hours}h` : '',
        minutes > 0 ? `${minutes}m` : '',
        `${seconds}s`
    ].filter(Boolean).join(' ');
    return formatted;
};

const newJobId = () => Math.random().toString(36).substring(2, 10).toUpperCase();

const running = {};

for (let file of await readdir(import.meta.dir, { recursive: false })) {

    if (!file.endsWith('.js') || file === 'index.js' || file === 'log.js') {
        continue;
    }
    
    if (!(file.startsWith("_") && file.endsWith("Worker.js"))) {
        continue;
    }

    const workerModule = require(`./${file}`);
    let worker = workerModule.default || workerModule;
    worker.file = file;

    if (!worker.description) {
        worker.description = file.replace(".js", "");
    }

    console.log(
        "\n" +
        colors.bg.blue + " WORKER SCHEDULED " + colors.reset + " " +
        colors.bright + colors.blue + worker.description + colors.reset +
        " at " + colors.dim + worker.file + colors.reset
    );

    const cronInfo = cronstrue.toString(worker.cron);
    console.log(
        `${logSymbols.calendar} Cron: ${colors.yellow}${worker.cron}${colors.reset} (${colors.dim}${cronInfo}${colors.reset})`
    );
    await addDbInfo("WORKER SCHEDULED " + worker.description + " (at " + worker.file + ") using cron " + worker.cron + " (" + cronInfo + ")");

    try {
        new CronJob(worker.cron, () => runTask(worker, true), null, true, 'UTC');
    } catch (e) {
        console.error(`${colors.bg.red} ERROR ${colors.reset} ${colors.bright}${colors.red} scheduling workker job ${worker.description} using cron expression ${worker.cron}${colors.reset}`);
        console.error(e);
        await addDbLog({level: "Error", message: `Error scheduling worker job ${worker.description} using cron expression ${worker.cron}: ${e.message}`, exception: e.stack, context: worker.description});
        console.log(`${colors.bg.red} EXITING ${colors.reset}`);
        process.exit(1);
    }

    if (worker.runOnStart) {
        runTask(worker, false);
    }
}

console.log(`\n${colors.bg.green} CRON SYSTEM READY ${colors.reset} ${formatTime()}\n`);
await addDbInfo("CRON SYSTEM READY");

async function runTask(worker, skipRunning, ...args) {
    const jobId = newJobId();

    if (skipRunning && running[worker.description]) {
        console.log(`${logSymbols.warning} ${colors.bright}PREVIOUS JOB IS STILL RUNNING, SKIPPING ${worker.description} [${jobId}]${colors.reset}`);
        await addDbLog({level: "Warning", message: `PREVIOUS JOB IS STILL RUNNING, SKIPPING ${jobId}`, context: worker.description});
        return;
    }

    running[worker.description] = true;
    let sql;
    const startTime = Date.now();
    let workerResult = false;
    
    console.log(
        `\n${logSymbols.info} ${colors.bright}Starting job ${colors.yellow}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] at ${formatTime()}`
    );
    //await addDbLog({ message: `STARTED ${jobId}`, context: worker.description });
    let duration;
    try {
        sql = SQL();
        workerResult = await worker(jobId, sql, ...args);
        duration = Date.now() - startTime;

        console.log(
            `${logSymbols.success} ${colors.bright}${colors.green}COMPLETED${colors.reset} ${colors.yellow}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] in ${colors.cyan}${formatDuration(duration)}${colors.reset}`
        );
    }
    catch (e) {
        console.error(`\n${colors.bg.red} ERROR ${colors.reset} ${colors.bright}${colors.red}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] at ${colors.dim}${worker.file}${colors.reset}`);
        console.error(`${colors.red}${colors.bright}${e.name || 'Error'}:${colors.reset} ${e.message}`);
        const errorDetails = [];
        if (e.fileName) {
            errorDetails.push(`File: ${e.fileName}`);
        }
        if (e.lineNumber) {
            errorDetails.push(`Line: ${e.lineNumber}${e.columnNumber ? `, Column: ${e.columnNumber}` : ''}`);
        }
        if (errorDetails.length > 0) {
            console.error(`${colors.dim}${errorDetails.join(' | ')}${colors.reset}`);
        }
        const errorObj = {};
        Object.getOwnPropertyNames(e).forEach(prop => {
            errorObj[prop] = e[prop];
        });
        const errLog = {
            jobId,
            source: worker.file,
            name: worker.description,
            message: e.message,
            duration: formatDuration(Date.now() - startTime),
            error: errorObj
        };
        await addDbLog({
            level: "Error",
            message: e.message,
            exception: JSON.stringify(errLog),
            context: worker.description || worker.file
        });
        if (!worker.keepAlive) {
            console.log(`${colors.bg.red} EXITING ${colors.reset}`);
            process.exit(1);
        }
    }
    finally {
        running[worker.description] = false;
        await sql.end();
    }
    if (workerResult) {
        await addDbLog({ message: `COMPLETED ${jobId} (Total runtime: ${duration})`, context: worker.description });
    }
    return jobId;
}

const sql = SQL();
await sql.listen('new_job_queue', payload => {
    const queueId = Number(payload);
    if (isNaN(queueId)) {
        error(`Receievd malformed payload for new_job_queue notification: '${payload}'. Expected existing job_queue ID number. Skipping this queue.`);
        return;
    }
    runTask(queuedWorker, true, queueId);
})
