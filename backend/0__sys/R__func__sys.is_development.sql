create or replace function sys.is_development()
returns text
language sql
stable
parallel safe
as
$$
select sys.setting('env') = 'development'
end;
$$;
