create table auth_email_confirmations (
    created_at timestamptz not null default now(),
    email text not null,
    code text not null,
    user_id bigint null,
    expires_at timestamptz null,
    confirmed_at timestamptz null,
    primary key (created_at, code)
) partition by range (created_at);
