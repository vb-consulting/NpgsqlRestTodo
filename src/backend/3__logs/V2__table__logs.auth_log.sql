create table logs.auth_log (
    at timestamptz not null default clock_timestamp(),
    type text not null,
    success boolean not null,
    message text not null,
    username text null,
    analytics jsonb not null,
    constraint type_check check (
        type = 'login' or
        type = 'external_login' or
        type = 'logout' or
        type = 'register' or
        type = 'confirm_email_code' or
        type = 'password_reset_code' or
        type = 'confirm_email' or
        type = 'password_reset'
    )
);

create index on logs.auth_log (at DESC);
create index on logs.auth_log (type);
create index on logs.auth_log (username);

select create_hypertable( 
    'logs.auth_log', 
    by_range('at', INTERVAL '1 month'), 
    migrate_data => false, 
    create_default_indexes => false
);

select add_retention_policy('logs.auth_log', INTERVAL '1 year');

call temporal.init('logs.auth_log');