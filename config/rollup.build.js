const { join, dirname, relative } = require("path");
const { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync, readdirSync, rmSync, statSync } = require("fs");
const { watch: chokidarWatch } = require("chokidar");
const { parseArgs } = require("util");
const { exit } = require("process");

const { 
    distPath, 
    assetsPath, 
    styleCss, 
    config, 
    error, 
    info, 
    chokidarWatchConfig, 
    buildTailwindCSS, 
    buildId, 
    envModuleOutput
} = require("./rollup.shared.js");

function cpy(from, to) {
    if (!existsSync(from)) {
        error(`ERROR: Could not find file '${from}'`);
        return;
    }
    if (!existsSync(to)) {
        mkdirSync(dirname(to), { recursive: true });
    }
    info(`${from} → ${to}...`);
    if (from.endsWith('.html')) {
        let content = readFileSync(from, 'utf8').replace(/\.css"|\.js"/g, function(match) {
            return match.replace('"', `?${buildId}"`);
        });
        writeFileSync(to, content);
    } else {
        copyFileSync(from, to);
    }
}

function emptyDist() {
    if (!existsSync(distPath)) {
        info(`${distPath} → created ...`);
        mkdirSync(distPath);
    } else {
        const files = readdirSync(distPath);
        for (const file of files) {
            const fullPath = join(distPath, file);
            info(`clearing → ${fullPath}...`);
            rmSync(fullPath, { recursive: true, force: true });
        }
        info(`${distPath} → cleared ...`);
    }
}

function copyAssets(dir) {
    let files = readdirSync(dir);
    for(let i = 0; i < files.length; i++) {
        let file = join(dir, files[i]);
        if (statSync(file).isDirectory()){
            copyAssets(file);
        } else {
            let destPath = join(distPath, relative(assetsPath, dir));
            let dest = join(destPath, files[i]);
            cpy(file, dest);
        }
    }
}

function createAuthSettingsFile() {
    if (process.env.AUTH_MIN_PASSWORD_LENGTH === undefined) {
        error("AUTH_MIN_PASSWORD_LENGTH is not set, perhaps you forgot the .env file?");
        exit(1);
    }
    writeFileSync(envModuleOutput, `// This file is auto-generated by the build process. Do not edit it manually.
export const AUTH_MAX_PASSWORD_LENGTH = ${process.env.AUTH_MAX_PASSWORD_LENGTH || 72};
export const AUTH_MIN_PASSWORD_LENGTH = ${process.env.AUTH_MIN_PASSWORD_LENGTH || 6};
export const AUTH_REQUIRED_UPPERCASE = ${process.env.AUTH_REQUIRED_UPPERCASE || 1};
export const AUTH_REQUIRED_LOWERCASE = ${process.env.AUTH_REQUIRED_LOWERCASE || 1};
export const AUTH_REQUIRED_NUMBER = ${process.env.AUTH_REQUIRED_NUMBER || 1};
export const AUTH_REQUIRED_SPECIAL = ${process.env.AUTH_REQUIRED_SPECIAL || 1};
export const AUTH_MAX_LOGIN_ATTEMPTS = ${process.env.AUTH_MAX_LOGIN_ATTEMPTS || 5};
`);
    info(`${envModuleOutput} → created...`);
}

const { values, positionals } = parseArgs({
    args: process.argv,
    options: {
        watch: {
            type: 'boolean',
        },
    },
    strict: true,
    allowPositionals: true,
});

const watch = values.watch;
const input  = positionals[2];

if (!existsSync(input)) {
    error(`Input path does not exist: ${input}`);
    exit(1);
}

emptyDist();
info(`Build ID → ${buildId}`);
copyAssets(assetsPath);
createAuthSettingsFile();

let files = [];

if (statSync(input).isDirectory()) {
    for (const file of readdirSync(input)) {
        const fullPath = "./" + join(input, file).replace(/\\/g, "/");
        if (!statSync(fullPath).isDirectory() && fullPath.endsWith('.ts')) {
            files.push(fullPath);
        }
    }
} else {
    if (!input.endsWith('.ts')) {
        error(`Input file must be a .ts file: ${input}`);
        exit(1);
    }
    files.push(input);
}

if (watch) {
    chokidarWatch(styleCss, chokidarWatchConfig).on("change", buildTailwindCSS);
    console.log(`[${new Date().toISOString().replace('T', ' ').substring(0, 19)}] watching ${styleCss} for changes...`);
}

let completed = 0;
for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const cmd = ["rollup", "--config", config, file];
    if (watch) {
        cmd.push("--watch");
    }
    Bun.spawn(cmd, {
        onExit(proc, exitCode, signalCode, error) {
            completed++;
            if (!watch && completed === files.length) {
                buildTailwindCSS();
            }
        }
    });
}
