create table job_queue (
    job_queue_id bigint generated always as identity primary key,
    payload jsonb not null,
    status char(1) not null,
    priority integer not null default 0,
    created_at timestamptz not null default now(),
    scheduled_for timestamptz not null default now(),
    started_at timestamptz null,
    completed_at timestamptz null,
    attempts integer not null default 0,
    max_attempts integer not null default 3,
    locked_by bigint null,
    locked_at timestamptz null,

    constraint status_check check (
        status = 'P' or -- pending
        status = 'F' or -- failed
        status = 'C' or -- completed
        status = 'R'    -- processing (running)
    )
);

comment on table job_queue is 'Queue for background jobs.';
comment on column job_queue.status is $$
status = 'P' or -- pending
status = 'F' or -- failed
status = 'C' or -- completed
status = 'R'    -- processing (running)
$$;

create index on job_queue (status, priority desc, scheduled_for) where status = 'P';
create index on job_queue (locked_by, locked_at) where locked_by is not null;
