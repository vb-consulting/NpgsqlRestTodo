call _.drop('auth.store_data_protection_keys');

create procedure auth.store_data_protection_keys(
    _name text,
    _data text
) 
security definer
language sql
as 
$$
insert into public.auth_data_protection_keys (name, data)
values (_name, _data)
on conflict (name) do update set data = excluded.data;
$$;
