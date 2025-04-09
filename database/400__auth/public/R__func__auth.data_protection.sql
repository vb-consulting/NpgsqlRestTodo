call sys.drop('auth.get_data_protection_keys');
create function auth.get_data_protection_keys()
returns setof text
security definer
language sql
as 
$$
select data from auth_data_protection_keys;
$$;

call sys.drop('auth.store_data_protection_keys');
create procedure auth.store_data_protection_keys(
    _name text,
    _data text
) 
security definer
language sql
as 
$$
insert into auth_data_protection_keys (name, data)
values (_name, _data)
on conflict (name) do update set data = excluded.data;
$$;
