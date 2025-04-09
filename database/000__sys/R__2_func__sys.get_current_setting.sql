/*
Function to get a setting from the current session and fallback to null if empty string or return a default value.
Note: default behavior of current_setting is to return empty string if setting has been removed (set to null).
*/
create or replace function sys.get_current_setting(
    _key text,
    _default text
)
returns text
language sql
stable
parallel safe
as
$$
select coalesce(nullif(pg_catalog.current_setting(_key, true), ''), _default);
$$;
