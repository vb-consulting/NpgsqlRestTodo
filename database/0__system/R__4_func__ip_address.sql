create function _.ip_address()
returns text
language sql
stable
parallel safe
as
$$
select _.setting('_.ip_address');
$$;
