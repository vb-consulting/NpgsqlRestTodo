create or replace function sys.is_development()
returns text
language sql
parallel safe
as
$$
select sys.setting('env') = 'development'
end;
$$;
