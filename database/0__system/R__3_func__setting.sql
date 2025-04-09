create or replace function _.setting(
    _key text
)
returns text
language sql
stable
parallel safe
as
$$
select case _key
    when 'now' then _.get_current_setting('_.now', now()::text)
    when 'muted' then _.get_current_setting('_.muted', '${MUTED}')
    when 'env' then _.get_current_setting('_.env', '${ENV}')
    when 'user_id' then _.get_current_setting('_.user_id', null)
    when 'user_name' then _.get_current_setting('_.user_name', null)
    when 'user_roles' then _.get_current_setting('_.user_roles', null)
    when 'ip_address' then _.get_current_setting('_.ip_address', null)
    else null
end;
$$;
