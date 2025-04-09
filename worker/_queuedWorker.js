const _batchSize = 5;
const _modulesDir = "./queue_modules";

/**
* @param {string} jobId
* @param {import('bun').SQL} sql
*/
async function job(jobId, sql, queueId) {
    let batchSize;
    if (queueId == undefined) {
        queueId = null;
        batchSize = _batchSize;
    } else {
        batchSize = 1;
    }
    let hasJobs = false
    await sql.begin(async sql => {
        for (let item of await sql`select job_queue_id, payload from app.dequeue_job(
            _worker_id => txid_current(), 
            _batch_size => ${batchSize}::int, 
            _job_queue_id => ${queueId}::bigint);`) { 

            if (!hasJobs) {
                hasJobs = true;
            }

            let queueId = item.job_queue_id;
            let params = item.payload.params;

            const module = require(`${_modulesDir}/${item.payload.module}`);
            const result = await (module.default || module)(...params, jobId, queueId);

            if (result) {
                await sql`select app.complete_job(${queueId}::bigint, txid_current())`;
            } else {
                await sql`select app.fail_job(${queueId}::bigint, txid_current())`;
            }
        }
    });
    return hasJobs;
};

job.cron = "*/2 * * * *"; // Every 2 minutes
job.description = "queued";
job.runOnStart = true;
job.keepAlive = false;

module.exports = job;
