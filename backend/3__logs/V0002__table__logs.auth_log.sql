create table logs.auth_log (
    at timestamptz not null default now(),
    type text not null,
    success boolean not null,
    message text not null,
    username text null,
    analytics_data jsonb not null,
    constraint type_check check (
        type = 'login' or
        type = 'logout' or
        type = 'register' or
        type = 'code'
    )
) partition by range (at);

create index on logs.auth_log (at);
create index on logs.auth_log (type);
create index on logs.auth_log (username);