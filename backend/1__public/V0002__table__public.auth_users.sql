create table auth_users (
    user_id bigint generated always as identity primary key,
    email text not null,
    password_hash text null,
    providers text[] not null default array[]::text[],
    provider_data jsonb null,

    confirmed boolean not null default false,

    expires_at timestamptz null,
    active_after timestamptz null,

    password_attempts int not null default 0,

    last_login_at timestamptz null,
    analytics_data jsonb not null default '{}',

    like sys.audit_template including all,

    constraint providers_check check (providers <@ array['password', 'google', 'github'])
);

create unique index on auth_users (email);

call sys.add_update_at_trigger('auth_users');
