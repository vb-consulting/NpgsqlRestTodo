call _.drop('auth.get_data_protection_keys');

create function auth.get_data_protection_keys()
returns setof text
security definer
language sql
as 
$$
select data from public.auth_data_protection_keys;
$$;
