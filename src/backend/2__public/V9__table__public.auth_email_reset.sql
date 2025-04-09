create table auth_email_resets (
    expires_at timestamptz not null,
    created_at timestamptz not null default now(),
    email text not null,
    code text not null,
    user_id bigint not null,
    link_opened_at timestamptz null,
    form_expires_at timestamptz null,
    token text null
);

create index on auth_email_resets (expires_at DESC);
create index on auth_email_resets (user_id, code);
create index on auth_email_resets (code, expires_at DESC);

select create_hypertable( 
    'auth_email_resets', 
    by_range('expires_at', INTERVAL '1 day'), 
    migrate_data => false, 
    create_default_indexes => false
);

select add_retention_policy('auth_email_resets', INTERVAL '1 month');

call temporal.init('auth_email_resets');