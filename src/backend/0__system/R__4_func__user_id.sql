/*
Get User Id of the current session. 
This setting is configured to be set by the npgsql server.
See NpgsqlRest.AuthenticationOptions.UserIdContextKey config setting.
*/
create function _.user_id()
returns bigint
language sql
stable
parallel safe
as
$$
select _.setting('_.user_id')::bigint;
$$;
