call sys.drop('app.dequeue_job');

create function app.dequeue_job(
    _worker_id bigint = txid_current(),
    _batch_size int = 5,
    _job_queue_id bigint = null
) 
returns table (
    job_queue_id bigint,
    payload jsonb
) 
language sql
security definer
as 
$$
with next_jobs as (
    select 
        jq.job_queue_id
    from 
        job_queue jq
    where (
            _job_queue_id is null 
            or jq.job_queue_id = _job_queue_id
        )
        and jq.status = 'pending'
        and jq.scheduled_for <= sys.setting('now')::timestamptz
        and jq.attempts < jq.max_attempts
        and jq.locked_by is null
    order by 
        jq.priority desc, jq.scheduled_for
    limit _batch_size
    for update skip locked
)
update job_queue jq
set 
    status = 'processing',
    locked_by = _worker_id,
    locked_at = sys.setting('now')::timestamptz,
    started_at = sys.setting('now')::timestamptz,
    attempts = attempts + 1
from 
    next_jobs
where 
    jq.job_queue_id = next_jobs.job_queue_id
returning 
    jq.job_queue_id, jq.payload;
$$;
