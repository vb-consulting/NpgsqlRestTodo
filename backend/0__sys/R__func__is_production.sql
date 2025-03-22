create or replace function sys.is_production()
returns text
language sql
stable
parallel safe
as
$$
select sys.setting('env') = 'production'
end;
$$;
