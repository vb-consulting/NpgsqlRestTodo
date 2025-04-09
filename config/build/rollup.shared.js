const { join, basename } = require("path");
const fs = require("fs");
const postcss = require("postcss");
const tailwindcss = require("@tailwindcss/postcss");

const distPathSuffix = "_dist";
const assetsPath = "/assets";
const config = "./config/build/rollup.config.js";
const envModuleOutput = "./src/_lib/env.ts";
const distinctEnvModule = "/api/env.ts";

const styleCss = "/style/style.css";
const distCss = (root) => {
    return join("./", (getLastPathSegment(root) + distPathSuffix), basename(styleCss)).replace(/\\/g, "/");
}

const error = msg => console.error("\x1b[31m" + msg + "\x1b[0m");
const warn = msg => console.warn("\x1b[33m" + msg + "\x1b[0m");
const info = msg => console.log("\x1b[96m" + msg + "\x1b[0m");

var chokidarWatchConfig = undefined;

if (process.env.DOCKER === 'true' && process.env.ENABLE_POLLING === 'true') {
    warn("Running in Docker with ENABLE_POLLING=true, using polling for file watching.");
    chokidarWatchConfig = {
        usePolling: true,
        interval: 500,
        awaitWriteFinish: {
            stabilityThreshold: 500,
            pollInterval: 100
        }
    };
}

async function buildTailwindCSS(root, production = false) {
    const startTime = performance.now();
    const styleCssPath = root + styleCss;
    try {
        const css = fs.readFileSync(styleCssPath, "utf8");
        const result = await postcss([
            tailwindcss({
                optimize: {
                    minify: production
                }
            }),
        ]).process(css, {
            from: styleCssPath,
            to: distCss(root),
            map: false
        });
        fs.writeFileSync(distCss(root), result.css);
        const duration = ((performance.now() - startTime) / 1000).toFixed(2);
        info(`tailwind build: ${styleCssPath} → ${distCss(root)} in ${duration}s`);
    } catch (err) {
        error('tailwind build: ' + styleCssPath + ' → ' + distCss(root) + ' → rebuild failed: ' + err);
        return;
    }
}

const d = new Date();
const buildId = 
    "v"+`${d.getFullYear().toString().slice(2)}${(d.getMonth()+1).toString().padStart(2,'0')}${d.getDate().toString().padStart(2,'0')}${d.getHours().toString().padStart(2,'0')}${d.getMinutes().toString().padStart(2,'0')}${d.getSeconds().toString().padStart(2,'0')}${d.getMilliseconds().toString().padStart(3,'0')}`;

function getLastPathSegment(input) {
    return input.indexOf("/") > -1 ? input.split("/").pop().split(".")[0] : input.split("\\").pop().split(".")[0];
}

module.exports = { 
    distPath: distPathSuffix, 
    assetsPath, 
    styleCss, 
    config, 
    distCss, 
    error, 
    warn, 
    info, 
    chokidarWatchConfig, 
    buildTailwindCSS,
    buildId,
    envModuleOutput,
    distinctEnvModule,
    getLastPathSegment
};
