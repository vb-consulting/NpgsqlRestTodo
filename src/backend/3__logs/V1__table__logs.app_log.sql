create table logs.app_log (
    at timestamptz not null default clock_timestamp(),
    level char(3) not null,
    message text not null,
    exception text,
    context text
    constraint level_check check (
        level = 'VRB' or -- verbose
        level = 'DBG' or -- debug
        level = 'INF' or -- info
        level = 'WRN' or -- warning
        level = 'ERR' or -- error
        level = 'FTL'    -- fatal
    )
);

--create unique index on logs.app_log (at DESC);
create index on logs.app_log (at DESC);
create index on logs.app_log (level);
create index on logs.app_log (context);

select create_hypertable( 
    'logs.app_log', 
    by_range('at', INTERVAL '1 month'), 
    migrate_data => false, 
    create_default_indexes => false
);

select add_retention_policy('logs.app_log', INTERVAL '1 year');

call temporal.init('logs.app_log');