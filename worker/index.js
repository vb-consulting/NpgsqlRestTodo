import { readdir } from "node:fs/promises";
import { CronJob } from "cron";
import cronstrue from "cronstrue";
import log from "./log.js";
import { SQL } from "bun";

const colors = {
    yellow: "\x1b[33m",
    cyan: "\x1b[36m",
    green: "\x1b[32m",
    red: "\x1b[31m",
    blue: "\x1b[34m",
    magenta: "\x1b[35m",
    reset: "\x1b[0m",
    bright: "\x1b[1m",
    dim: "\x1b[2m",
    bg: {
        cyan: "\x1b[46m",
        blue: "\x1b[44m",
        green: "\x1b[42m",
        red: "\x1b[41m",
    }
};

const logSymbols = {
    info: colors.blue + "ℹ" + colors.reset,
    success: colors.green + "✓" + colors.reset,
    warning: colors.yellow + "⚠" + colors.reset,
    error: colors.red + "✖" + colors.reset,
    clock: colors.cyan + "⏱" + colors.reset,
    calendar: colors.magenta + "📅" + colors.reset,
    file: colors.cyan + "📄" + colors.reset
};

const formatTime = () => {
    return new Date().toISOString().replace('T', ' ').slice(0, 19);
};

const info = async message => log({message, context: "worker"});

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

    console.log(
        `${logSymbols.calendar} Cron: ${colors.yellow}${worker.cron}${colors.reset} (${colors.dim}${cronstrue.toString(worker.cron)}${colors.reset})`
    );

    await info("WORKER SCHEDULED " + worker.description + " (at " + worker.file + ") using cron " + worker.cron + " (" + cronstrue.toString(worker.cron) + ")");

    const task = async function () {
        if (running[worker.description]) {
            console.log(`${logSymbols.warning} ${colors.bright}PREVIOUS JOB IS STILL RUNNING, SKIPPING ${worker.description} [${jobId}]${colors.reset}`);
            await log({level: "Warning", message: `PREVIOUS JOB IS STILL RUNNING, SKIPPING ${jobId}`, context: worker.description});
            return;
        }
        running[worker.description] = true;
        let sql;
        const startTime = Date.now();
        const jobId = Math.random().toString(36).substring(2, 10).toUpperCase();
        console.log(
            `\n${logSymbols.info} ${colors.bright}Starting job ${colors.yellow}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] at ${formatTime()}`
        );
        await log({message: `STARTED ${jobId}`, context: worker.description})
        try {
            sql = new SQL();
            await worker(jobId, sql);
            const duration = Date.now() - startTime;
            console.log(
                `${logSymbols.success} ${colors.bright}${colors.green}Completed${colors.reset} ${colors.yellow}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] in ${colors.cyan}${formatDuration(duration)}${colors.reset}`
            );
        }
        catch (e) {
            console.error(`\n${colors.bg.red} ERROR ${colors.reset} ${colors.bright}${colors.red}${worker.description}${colors.reset} [${colors.dim}${jobId}${colors.reset}] at ${colors.dim}${worker.file}${colors.reset}`);
            console.error(`${colors.red}${colors.bright}${e.name || 'Error'}:${colors.reset} ${e.message}`);
            const errLog = {
                jobId,
                source: worker.file,
                name: worker.description,
                message: e.message,
                duration: formatDuration(Date.now() - startTime)
            };
            const errorDetails = [];
            if (e.fileName) {
                errorDetails.push(`File: ${e.fileName}`);
                errLog.fileName = e.fileName;
            }
            if (e.lineNumber) {
                const location = `Line: ${e.lineNumber}${e.columnNumber ? `, Column: ${e.columnNumber}` : ''}`;
                errLog.lineNumber = e.lineNumber;
                e.columnNumber && (errLog.columnNumber = e.columnNumber);
                errorDetails.push(location);
            }
            if (errorDetails.length > 0) {
                console.error(`${colors.dim}${errorDetails.join(' | ')}${colors.reset}`);
            }
            if (e.cause) {
                console.error(`${colors.dim}Caused by:${colors.reset} ${e.cause}`);
                errLog.cause = e.cause;
            }
            if (e.stack) {
                const stackLines = e.stack.split('\n');
                console.error(`\n${colors.dim}Stack trace:${colors.reset}`);
                stackLines.forEach((line, index) => {
                    if (index > 0) {
                        console.error(`  ${colors.dim}${index}.${colors.reset} ${line}`);
                    }
                });
                errLog.stack = e.stack;
            }
            await log({
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
        const duration = formatDuration(Date.now() - startTime);
        await log({message: `FINISHED ${jobId} (Total runtime: ${duration})`, context: worker.description})
        console.log(
            `${logSymbols.clock} ${colors.dim}Total runtime: ${duration}${colors.reset}\n`
        );
    };

    try {
        new CronJob(worker.cron, task, null, true, 'UTC');
    } catch (e) {
        console.error(`${colors.bg.red} ERROR ${colors.reset} ${colors.bright}${colors.red} scheduling workker job ${worker.description} using cron expression ${worker.cron}${colors.reset}`);
        console.error(e);
        await log({level: "Error", message: `Error scheduling workker job ${worker.description} using cron expression ${worker.cron}: ${e.message}`, exception: e.stack, context: worker.description});
        console.log(`${colors.bg.red} EXITING ${colors.reset}`);
        process.exit(1);
    }

    if (worker.runOnStart) {
        task();
    }
}

console.log(`\n${colors.bg.green} CRON SYSTEM READY ${colors.reset} ${formatTime()}\n`);
await info("CRON SYSTEM READY");