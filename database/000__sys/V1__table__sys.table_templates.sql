create table sys.timestamp_audit_template (
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table sys.user_audit_template (
    updated_by bigint null,-- default sys.setting('user_id')::bigint,
    created_by bigint null-- default sys.setting('user_id')::bigint
);

create table sys.audit_template (
    like sys.timestamp_audit_template including all,
    like sys.user_audit_template including all
);
