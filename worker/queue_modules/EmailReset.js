const log = require("../log.js");
const path = require("path");

const context = __filename.split(path.sep).slice(-1)[0];

module.exports = async function (email, code, userId, jobId, queueId) {
    const url = `${process.env.APP_URL}/reset#`.replaceAll("//", "/") + Buffer.from(JSON.stringify({code, email})).toString('base64');
    const info = `email: ${email}, code: ${code}, userId: ${userId}, jobId: ${jobId}, queueId: ${queueId}, url: ${url}`;
    try {
        // Simulate sending email
        await new Promise((resolve) => setTimeout(resolve, 1000));

        const message = `Reset email sent. Info: ${info}`;
        log.info(message);
        await log.addDbLog({ level: "Information", message, context });
    } catch (error) {
        const message = `Error sending reset email. Info: ${info}`;
        log.error(message);
        await log.addDbLog({
            level: "Error",
            message,
            exception: JSON.stringify(error, Object.getOwnPropertyNames(error)),
            context
        });
        return false;
    }

    return true;
}