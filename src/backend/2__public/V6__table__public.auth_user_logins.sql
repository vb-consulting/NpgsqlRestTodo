create table auth_user_logins (
    login_at timestamptz not null default now(),
    email text not null,
    user_id bigint null references auth_users 
        on delete set null deferrable initially immediate,
    provider_id int not null references auth_providers (provider_id) 
        on delete set null deferrable initially immediate,
    provider_data jsonb not null default '{}',
    analytics jsonb not null default '{}'
);

create index on auth_user_logins (login_at DESC);
create index on auth_user_logins (email);
create index on auth_user_logins (user_id);
create index on auth_user_logins (email, login_at DESC);
create index on auth_user_logins (user_id, login_at DESC);

select create_hypertable( 
    'public.auth_user_logins', 
    by_range('login_at', INTERVAL '1 month'), 
    migrate_data => false, 
    create_default_indexes => false
);

call temporal.init('auth_user_logins');