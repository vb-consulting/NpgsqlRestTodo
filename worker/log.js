import { SQL } from "bun";

export default async function log({level, message, timestamp, exception, context}) {
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
    }
    if (context && typeof context !== "string") {
        throw new Error("Context must be a string");
    }
    if (!timestamp) {
        timestamp = new Date();
    }
    const sql = new SQL();
    await sql`CALL app.log(
        _level => ${level}::text, 
        _message => ${message}::text, 
        _log_timestamp => ${timestamp}::timestamptz, 
        _exception => ${exception}::text, 
        _context => ${context}::text
    )`;
    await sql.end();
}