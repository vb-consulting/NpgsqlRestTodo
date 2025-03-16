/*
Define system settings. 
Note: now is used here so that it can be set manually for testing purposes.
*/
create or replace function sys.setting(
    _key text
)
returns text
language sql
stable
parallel safe
as
$$
select case _key
    when 'now' then sys.get_current_setting('public.now', now()::text)
    when 'muted' then sys.get_current_setting('public.muted', '${PUBLIC_MUTED}')
    else null
end;
$$;
