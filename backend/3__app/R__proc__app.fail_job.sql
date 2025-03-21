call sys.drop('app.fail_job');

create function app.fail_job(
    _job_queue_id bigint,
    _worker_id bigint = txid_current(),
    _delay_interval interval = '1 minute'
) 
returns boolean 
language plpgsql
security definer
as 
$$
begin
    update job_queue
    set 
        status = case 
            when attempts >= max_attempts then 'F' 
            else 'P' 
        end,
        scheduled_for = case 
            when attempts >= max_attempts then scheduled_for 
            else sys.setting('now')::timestamptz + _delay_interval
        end,
        locked_by = null,
        locked_at = null
    where 
        job_queue_id = _job_queue_id 
        and locked_by = _worker_id;

    return found;
end;
$$;
