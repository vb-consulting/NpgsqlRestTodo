const { join, basename } = require("path");
const fs = require("fs");
const postcss = require("postcss");
const tailwindcss = require("@tailwindcss/postcss");

const distPath = "./dist";
const assetsPath = "./src/assets";
const styleCss = "./src/style/style.css";
const config = "./config/rollup.config.js";
const distCss = join(distPath, basename(styleCss)).replace(/\\/g, "/");
const envModuleOutput = "./src/api/_env.ts";

const error = msg => console.error("\x1b[31m" + msg + "\x1b[0m");
const warn = msg => console.warn("\x1b[33m" + msg + "\x1b[0m");
const info = msg => console.log("\x1b[94m" + msg + "\x1b[0m");

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

async function buildTailwindCSS(production = false) {
    try {
        const css = fs.readFileSync(styleCss, "utf8");
        const result = await postcss([
            tailwindcss({
                optimize: {
                    minify: production
                }
            }),
        ]).process(css, {
            from: styleCss,
            to: distCss,
            map: false
        });
        fs.writeFileSync(distCss, result.css);
    } catch (err) {
        error(styleCss + ' → ' + distCss + ' → rebuild failed: ' + err);
        return;
    }
    info(styleCss + ' → ' + distCss);
}

const d = new Date();
const buildId = "v"+`${d.getFullYear().toString().slice(2)}${(d.getMonth()+1).toString().padStart(2,'0')}${d.getDate().toString().padStart(2,'0')}${d.getHours().toString().padStart(2,'0')}${d.getMinutes().toString().padStart(2,'0')}${d.getSeconds().toString().padStart(2,'0')}${d.getMilliseconds().toString().padStart(3,'0')}`;

module.exports = { 
    distPath, 
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
    envModuleOutput
};

