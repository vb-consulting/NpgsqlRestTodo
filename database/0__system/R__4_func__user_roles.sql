create function _.user_roles()
returns text[]
language sql
stable
parallel safe
as
$$
select _.setting('_.user_roles')::text[];
$$;

