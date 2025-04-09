/*
Get the current setting for a configuration parameter.
This function retrieves the value of a specified configuration parameter from the PostgreSQL server.
*/
create function _.get_current_setting(
    _key text,
    _default text = null
)
returns text
language sql
stable
parallel safe
as
$$
select coalesce(nullif(pg_catalog.current_setting(_key, true), ''), _default);
$$;
