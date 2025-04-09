create function _.is_production()
returns text
language sql
stable
parallel safe
as
$$
select _.setting('env') = 'production';
$$;
