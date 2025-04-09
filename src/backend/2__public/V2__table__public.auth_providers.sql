create table auth_providers (
    provider_id int generated always as identity primary key,
    name text not null,
    description text null,
    like _.audit_template including all
);

call _.add_audit_trigger('auth_providers');
call temporal.init('auth_providers');

insert into auth_providers 
(provider_id, name) 
overriding system value
select 
    row_number() over () as provider_id,
    name
from unnest('${DEFAULT_PROVIDERS}'::text[]) as name;
