import SQL from './db.js';

export const colors = {
    yellow: "\x1b[33m",
    cyan: "\x1b[36m",
    green: "\x1b[32m",
    red: "\x1b[31m",
    blue: "\x1b[34m",
    magenta: "\x1b[35m",
    reset: "\x1b[0m",
    bright: "\x1b[1m",
    dim: "\x1b[2m",
    brightCyan: "\x1b[96m",
    brightBlue: "\x1b[94m",
    bg: {
        cyan: "\x1b[46m",
        blue: "\x1b[44m",
        green: "\x1b[42m",
        red: "\x1b[41m",
        yellow: "\x1b[43m",
        magenta: "\x1b[45m",
        brightCyan: "\x1b[106m",
        brightBlue: "\x1b[104m",
    }
};

export const logSymbols = {
    info: colors.blue + "ℹ" + colors.reset,
    success: colors.green + "✓" + colors.reset,
    warning: colors.yellow + "⚠" + colors.reset,
    error: colors.red + "✖" + colors.reset,
    clock: colors.cyan + "⏱    " + colors.reset,
    calendar: colors.magenta + "📅    " + colors.reset,
};

const formatTime = () => new Date().toISOString().replace('T', ' ').slice(0, 19);

const logContext = (context) => {
    if (context) {
        console.log(`${colors.dim}${context}:${colors.reset}`);
    }
}

export const warning = (message, context) => {
    logContext(context);
    console.log(`${colors.bg.yellow} ⚠ WARN ${colors.reset} ${colors.yellow}${message}${colors.reset} ${colors.dim} at ${formatTime()}${colors.reset}`);
    console.log();
}
export const error = (message, context) => {
    logContext(context);
    console.log(`${colors.bg.red} ✖ ERROR ${colors.reset} ${colors.red}${message}${colors.reset} ${colors.dim} at ${formatTime()}${colors.reset}`);
    console.log();
}
export const info = (message, context) => {
    logContext(context);
    console.log(`${colors.bg.blue} ℹ INFO ${colors.reset} ${colors.blue}${message}${colors.reset} ${colors.dim} at ${formatTime()}${colors.reset}`);
    console.log();
}
export const notice = (message, context) => {
    logContext(context);
    console.log(`${colors.bg.brightBlue} ✓ NOTICE ${colors.reset} ${colors.brightBlue}${message}${colors.reset} ${colors.dim} at ${formatTime()}${colors.reset}`);
    console.log();
}

export async function addDbLog({level, message, timestamp, exception, context}) {
    if (!level) {
        level = "Information";
    }
    if (level !== "Information" && level !== "Warning" && level !== "Error" && level !== "Debug" && level !== "Verbose") {
        throw new Error("Invalid log level");
    }
    if (!message) {
        throw new Error("Message is required");
    }
    if (exception && typeof exception !== "string") {
        throw new Error("Exception must be a string");
    } else {
        exception = exception || null;
    }
    if (context && typeof context !== "string") {
        throw new Error("Context must be a string");
    } else {
        context = context || null;
    }
    if (!timestamp) {
        timestamp = new Date();
    }
    const sql = SQL();
    await sql`CALL app.log(
        _level => ${level}::text, 
        _message => ${message}::text, 
        _log_timestamp => ${timestamp}::timestamptz, 
        _exception => ${exception}::text, 
        _context => ${context}::text
    )`;
    await sql.end();
}