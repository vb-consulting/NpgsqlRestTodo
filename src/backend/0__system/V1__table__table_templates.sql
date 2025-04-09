/*
Audit table templates for to be used in other tables.
*/

create table _.timestamp_audit_template (
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table _.user_audit_template (
    updated_by bigint null,
    created_by bigint null
);

create table _.audit_template (
    like _.timestamp_audit_template including all,
    like _.user_audit_template including all
);
