/*
Append the current IP address to the analytics JSONB object.
*/
create function _.append_ip_address(
    _analytics jsonb
)
returns jsonb
language sql
stable
parallel safe
as
$$
select coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('ip', _.ip_address());
$$;
