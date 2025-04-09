create table auth_roles (
    role_id int primary key,
    name text not null,
    description text null,

    like sys.audit_template including all
);

call sys.add_update_at_trigger('auth_roles');

insert into auth_roles 
(role_id, name) 
select 
    row_number() over () as role_id,
    name
from unnest('${DEFAULT_ROLES}'::text[]) as name;
