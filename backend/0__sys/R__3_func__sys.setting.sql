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
    when 'now' then sys.get_current_setting('sys.now', now()::text)
    when 'muted' then sys.get_current_setting('sys.muted', '${SYS_MUTED}')
    when 'env' then sys.get_current_setting('sys.env', '${SYS_ENV}')
    else null
end;
$$;
