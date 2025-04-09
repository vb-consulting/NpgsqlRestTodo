create table job_queue (
    job_queue_id bigint generated always as identity primary key,
    payload jsonb not null,
    status text not null,
    priority integer not null default 0,
    created_at timestamptz not null default now(),
    scheduled_for timestamptz not null default now(),
    started_at timestamptz null,
    completed_at timestamptz null,
    attempts integer not null default 0,
    max_attempts integer not null default 3,
    locked_by bigint null,
    locked_at timestamptz null,
    delay_retry interval default '2 minutes'
    constraint status_check check (status = 'pending' or status = 'failed' or status = 'completed' or status = 'processing')
);

comment on table job_queue is 'Queue for background jobs.';

create index on job_queue (status, priority desc, scheduled_for) where status = 'pending';
create index on job_queue (locked_by, locked_at) where locked_by is not null;


call temporal.init('job_queue');