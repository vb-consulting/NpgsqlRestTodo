create table logs.app_log (
    at timestamptz not null default now(),
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
) partition by range (at);

create index on logs.app_log (at);
create index on logs.app_log (level);
create index on logs.app_log (context);