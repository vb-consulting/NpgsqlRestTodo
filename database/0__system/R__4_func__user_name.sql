/*
Get User Name of the current session. 
This setting is configured to be set by the npgsql server.
See NpgsqlRest.AuthenticationOptions.UserNameContextKey config setting.
*/
create function _.user_name()
returns text
language sql
stable
parallel safe
as
$$
select _.setting('_.user_name');
$$;
