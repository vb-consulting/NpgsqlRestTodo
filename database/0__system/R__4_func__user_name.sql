create function _.user_name()
returns text
language sql
stable
parallel safe
as
$$
select _.setting('_.user_name');
$$;
