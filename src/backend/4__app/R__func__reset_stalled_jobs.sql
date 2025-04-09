create function _.reset_stalled_jobs(
    _timeout_interval interval = '1 hour'
)
returns bigint 
language sql
as 
$$
with updated_jobs as (
    update public.job_queue
    set 
        status = 'pending', 
        locked_by = null, 
        locked_at = null
    where 
        status = 'processing' 
        and locked_at < (_.setting('now')::timestamptz - _timeout_interval)
    returning 1
)
select count(*)::bigint from updated_jobs;
$$;
