call _.drop('app.enqueue_job');

create function app.enqueue_job(
    _payload jsonb,
    _priority integer = 0,
    _scheduled_for timestamptz = _.setting('now')::timestamptz,
    _max_attempts integer = 3,
    _delay_retry interval = '2 minutes'
) 
returns bigint 
language plpgsql
security definer
set search_path = public, pg_catalog
as 
$$
declare
    _job_id bigint;
begin
    insert into public.job_queue (
        payload, 
        priority, 
        scheduled_for, 
        max_attempts, 
        status, 
        delay_retry
    )
    values (
        _payload, 
        _priority, 
        _scheduled_for, 
        _max_attempts, 
        'pending', 
        _delay_retry
    )
    returning job_queue_id
    into _job_id;

    perform pg_catalog.pg_notify('new_job_queue', _job_id::text);

    return _job_id;
end;
$$;
