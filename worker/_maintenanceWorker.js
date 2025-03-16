/**
* @param {string} jobId
* @param {import('bun').SQL} sql
*/
async function job(jobId, sql) {
    await sql`call app.maintenance_job()`;
};

job.cron = "0 0,12 * * *";
job.description = "maintenance";
job.runOnStart = true;
job.keepAlive = false;

module.exports = job;
