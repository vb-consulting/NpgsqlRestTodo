create table auth_roles (
    role_id int primary key,
    name text not null,
    description text null,

    like _.audit_template including all
);

call _.add_audit_trigger('auth_roles');
call temporal.init('auth_roles');

insert into auth_roles 
(role_id, name) 
select 
    row_number() over () as role_id,
    name
from unnest('${DEFAULT_ROLES}'::text[]) as name;
