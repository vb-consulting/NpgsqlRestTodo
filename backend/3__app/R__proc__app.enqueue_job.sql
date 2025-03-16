call sys.drop('app.enqueue_job');

create function app.enqueue_job(
    _payload jsonb,
    _priority integer = 0,
    _scheduled_for timestamptz = sys.setting('now')::timestamptz,
    _max_attempts integer = 3
) 
returns bigint 
language sql
security definer
as 
$$
insert into job_queue 
    (payload, priority, scheduled_for, max_attempts, status)
values 
    (_payload, _priority, _scheduled_for, _max_attempts, 'P')
returning job_queue_id;
$$;
