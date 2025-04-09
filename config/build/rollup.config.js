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
const { exit } = require("process");
const join = path.join;
const _resolve = path.resolve;

const { distPath, chokidarWatchConfig, buildTailwindCSS, info, error, getLastPathSegment } = require("./rollup.shared.js");
const production = !process.env.ROLLUP_WATCH;

function rollupPlugin(root) {
    return {
        name: 'watch-build-end',
        watchChange(id) {
            info('build → ' + id);
        },
        buildEnd() {
            buildTailwindCSS(root);
        }
    }
};

module.exports = args => {
    const input = args.input.toString();
    const root = args.configRoot.toString();

    if (!input || !root) {
        error(`--input and --configRoot parameters must be specified`);
        exit(1);
    }

    const appObject = getLastPathSegment(input);
    const distRoot = join("./", (getLastPathSegment(root) + distPath));
    const distFile = join(distRoot, appObject);
    const cssOutput = distFile + ".css";
    const jsOutput = distFile + ".js";

    return {
        input: input,
        output: {
            sourcemap: !production,
            format: "iife",
            file: jsOutput,
            name: appObject,
            globals: {}
        },
        cache: true,
        plugins: [
            !production && rollupPlugin(root),
            alias({
                entries: [
                    { find: "$lib", replacement: _resolve(__dirname, `../../src/_lib`) }
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
                tsconfig: "tsconfig.json",
                outputToFilesystem: true
            }),
            svelte({
                preprocess: sveltePreprocess({ 
                    sourceMap: !production,
                    cache: true,
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
                        fs.writeFileSync(cssOutput, compileString(styles, {syntax: "css", style: "compressed"}).css);
                    } else {
                        fs.writeFileSync(cssOutput, styles);
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