create table logs.auth_log (
    at timestamptz not null default now(),
    type char(1) not null,
    success boolean not null,
    message text not null,
    username text null,
    data json not null,
    constraint type_check check (
        type = 'I' or   -- loging
        type = 'O' or   -- logout
        type = 'R'      -- register
    )
) partition by range (at);
