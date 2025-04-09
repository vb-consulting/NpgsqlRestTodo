call _.drop('_.set_current_setting');

/*
Set the value of a run-time parameter for the current session. 
Note: this value will be lost when the session ends. 
To set a value for all sessions, use ALTER SYSTEM SET configuration_parameter TO or set the value in the postgresql.conf file.

Only superusers can change the value of a parameter with this function.
*/
create procedure _.set_current_setting(
    _key text,
    _value text
)
language sql
as
$$
select pg_catalog.set_config(_key, _value, true); 
$$;
