call _.drop('app.fail_job');

create function app.fail_job(
    _job_queue_id bigint,
    _worker_id bigint = txid_current(),
    _delay_retry interval = null -- null means use the default delay_retry
) 
returns boolean 
language plpgsql
security definer
as 
$$
begin
    update public.job_queue
    set 
        status = case 
            when attempts >= max_attempts then 'failed' else 'pending' 
        end,
        scheduled_for = case 
            when attempts >= max_attempts then scheduled_for 
            else _.setting('now')::timestamptz + coalesce(_delay_retry, delay_retry)::interval
        end,
        locked_by = null,
        locked_at = null
    where 
        job_queue_id = _job_queue_id 
        and locked_by = _worker_id;

    return found;
end;
$$;
