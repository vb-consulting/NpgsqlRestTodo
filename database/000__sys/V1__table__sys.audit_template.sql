create table sys.audit_template (
    created_at timestamp not null default now(),
    updated_at timestamp not null default now()
);
