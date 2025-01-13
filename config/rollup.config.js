const svelte = require("rollup-plugin-svelte");
const commonjs = require("@rollup/plugin-commonjs");
const resolve = require("@rollup/plugin-node-resolve");
const terser = require("@rollup/plugin-terser");
const sveltePreprocess = require("svelte-preprocess");
const typescript = require("@rollup/plugin-typescript");
const css = require("rollup-plugin-css-only");
const { compileString } = require('sass');
const replace = require('@rollup/plugin-replace');
const alias = require("@rollup/plugin-alias");
const path = require("path");
const fs = require("fs");
const join = path.join;
const _resolve = path.resolve;

const { distPath, chokidarWatchConfig, buildTailwindCSS, info } = require("./rollup.shared.js");
const production = !process.env.ROLLUP_WATCH;

function rollupPlugin(options = {}) {
    return {
        name: 'watch-build-end',
        watchChange(id) {
            info('build → ' + "./src/" + id.replace(/\\/g, "/").split("/src/")[1]);
        },
        buildEnd() {
            buildTailwindCSS();
        }
    }
};

module.exports = args => {
    const input = args.input[0];
    let appObject = input.indexOf("/") > -1 ? input.split("/").pop().split(".")[0] : input.split("\\").pop().split(".")[0];
    const cssOutput = appObject + ".css";
    const jsOutput = join(distPath, appObject + ".js");
    return {
        input: input,
        output: {
            sourcemap: !production,
            format: "iife",
            file: jsOutput,
            name: appObject,
            globals: {}
        },
        plugins: [
            !production && rollupPlugin(),
            alias({
                entries: [
                    { find: "$api", replacement:  _resolve(__dirname, "../src/api") },
                    { find: "$lib", replacement:  _resolve(__dirname, "../src/app/lib") },
                    { find: "$part", replacement:  _resolve(__dirname, "../src/app/part") }
                ]
            }),
            replace({
                preventAssignment: true,
                "process.env.NODE_ENV": JSON.stringify("development")
            }),
            typescript({
                sourceMap: !production,
                inlineSources: !production,
                noEmitOnError: !production,
                tsconfig: "tsconfig.json"
            }),
            svelte({
                preprocess: sveltePreprocess({ 
                    sourceMap: !production,
                }),
                compilerOptions: {
                    // enable run-time checks when not in production
                    dev: !production,
                    customElement: false,
                }
            }),
            // we"ll extract any component CSS out into
            // a separate file - better for performance
            css({ 
                output: async function(styles, bundle) {
                    if (production) {
                        fs.writeFileSync(join(distPath, cssOutput), compileString(styles, {syntax: "css", style: "compressed"}).css);
                    } else {
                        fs.writeFileSync(join(distPath, cssOutput), styles);
                    }
                }
            }),
            // If you have external dependencies installed from
            // npm, you"ll most likely need these plugins. In
            // some cases you"ll need additional configuration -
            // consult the documentation for details:
            // https://github.com/rollup/plugins/tree/master/packages/commonjs
            resolve({
                browser: true,
                dedupe: ["svelte"],
                extensions: [".svelte", ".ts", ".json", ".js"]
            }),
            commonjs({ 
                sourceMap: !production 
            }),

            // If we"re building for production (npm run build
            // instead of npm run watch), minify
            production && terser()
        ],
        onwarn(warning, warn) {
            if (warning.code === 'CIRCULAR_DEPENDENCY') {
                return;
            }
            warn(warning);
        },
        watch: {
            clearScreen: false,
            chokidar: chokidarWatchConfig
        }
    };
};