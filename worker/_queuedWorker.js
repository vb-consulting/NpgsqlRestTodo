/**
* @param {string} jobId
* @param {import('bun').SQL} sql
*/
async function job(jobId, sql) {
    sql`begin;`;
    for(let item of await sql`select job_queue_id, payload from app.queued_job()`) {
        //  send email for each job_id
        // if mail sent:
        //     SELECT complete_job(job_id, txid_current()::text);
        // else:
        //     SELECT fail_job(job_id, txid_current()::text);
    }
    sql`end;`;
};

job.cron = "*/5 * * * *";
job.description = "queued";
job.runOnStart = false;
job.keepAlive = false;

module.exports = job;
