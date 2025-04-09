create table auth_users (
    user_id bigint generated always as identity primary key,
    email text not null,
    password_hash bytea null,
    password_confirmed boolean not null default false,
    expires_at timestamptz null,
    active_after timestamptz null,
    password_attempts int not null default 0,

    like sys.audit_template including all
);

create unique index on auth_users (email);
call sys.add_update_at_trigger('auth_users');
