create function _.user_id()
returns bigint
language sql
stable
parallel safe
as
$$
select _.setting('_.user_id')::bigint;
$$;
