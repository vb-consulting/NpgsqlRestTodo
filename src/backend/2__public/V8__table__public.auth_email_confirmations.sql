create table auth_email_confirmations (
    expires_at timestamptz not null,
    created_at timestamptz not null default now(),
    email text not null,
    code text not null,
    user_id bigint not null,
    confirmed_at timestamptz null
);

create index on auth_email_confirmations (expires_at DESC);
create index on auth_email_confirmations (code, expires_at DESC);
create index on auth_email_confirmations (user_id, code);

select create_hypertable( 
    'auth_email_confirmations', 
    by_range('expires_at', INTERVAL '1 day'), 
    migrate_data => false, 
    create_default_indexes => false
);

select add_retention_policy('auth_email_confirmations', INTERVAL '1 month');

call temporal.init('auth_email_confirmations');