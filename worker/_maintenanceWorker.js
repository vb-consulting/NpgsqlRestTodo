/**
* @param {string} jobId
* @param {import('postgres').Sql<{}>} sql
*/
async function job(jobId, sql) {
    await sql`call app.maintenance_job()`;
};

job.cron = "0 0 * * *"; // Every day at midnight
job.description = "maintenance";
job.runOnStart = true;
job.keepAlive = false;

module.exports = job;
