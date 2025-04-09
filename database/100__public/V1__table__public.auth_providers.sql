create table auth_providers (
    provider_id int generated always as identity primary key,
    name text not null,
    description text null
);

insert into auth_providers 
(provider_id, name) 
overriding system value
select 
    row_number() over () as provider_id,
    name
from unnest('${DEFAULT_PROVIDERS}'::text[]) as name;
