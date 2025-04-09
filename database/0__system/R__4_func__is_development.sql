/*
Get the current environment setting. This function checks if the current environment is set to 'development'.
Environment settings are are set by the migration tool envionment variables.
*/
create function _.is_development()
returns text
language sql
parallel safe
as
$$
select _.setting('env') = 'development';
$$;
