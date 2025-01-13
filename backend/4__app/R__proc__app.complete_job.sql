call sys.drop('app.complete_job');

create function app.complete_job(
    _job_queue_id bigint,
    _worker_id bigint = txid_current()
) 
returns boolean 
language plpgsql
security definer
as 
$$
begin
    update job_queue
    set 
        status = 'completed',
        completed_at = sys.setting('now')::timestamptz,
        locked_by = null,
        locked_at = null
    where 
        job_queue_id = _job_queue_id 
        and locked_by = _worker_id;

    return found;
end;
$$;
