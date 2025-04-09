call _.drop('app.get_session_password_hash');

/*
Lookup function for pgbouncer to get session password SCRAM-SHA-256 hash for database connections.
See AUTH_QUERY in pgbouncer config.
*/
create function app.get_session_password_hash(
    _user name
)
returns record
security definer
language sql
set search_path = public, pg_catalog
as 
$$
select usename, passwd 
from pg_catalog.pg_shadow
where usename = _user
$$;

revoke execute on function app.get_session_password_hash(name) from public;
grant execute on function app.get_session_password_hash(name) to ${PGBOUNCER_USER};
