create function _.is_development()
returns text
language sql
parallel safe
as
$$
select _.setting('env') = 'development';
$$;
