/*
Get User Roles of the current session. 
This setting is configured to be set by the npgsql server.
See NpgsqlRest.AuthenticationOptions.UserRolesContextKey config setting.
*/
create function _.user_roles()
returns text[]
language sql
stable
parallel safe
as
$$
select _.setting('_.user_roles')::text[];
$$;

