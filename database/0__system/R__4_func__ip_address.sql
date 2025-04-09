/*
Get IP address of the current session. 
This setting is configured to be set by the npgsql server.
See NpgsqlRest.AuthenticationOptions.IpAddressContextKey config setting.
*/
create function _.ip_address()
returns text
language sql
stable
parallel safe
as
$$
select _.setting('_.ip_address');
$$;
