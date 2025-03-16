call sys.drop('sys.ensure_monthly_partition');
/*
Ensures that monthly partition is created for the table name from arguments.
Monthly partition will be in format schema.table_YYYYMM (e.g. logs.auth_log_202503)
*/
create procedure sys.ensure_monthly_partition(
    _schema text,
    _table text,
    _timestamp timestamptz = now()
) 
language plpgsql
as 
$$
declare 
    _partition text = _table || '_' || to_char(_timestamp, 'YYYYMM');
    _start_date timestamptz;
    _end_date timestamptz;
begin
    if not exists (
        select 1 from information_schema.tables
        where table_schema = _schema and table_name = _partition
    ) then
        _start_date = date_trunc('month', _timestamp);
        _end_date = _start_date + interval '1 month';
        begin
            execute format(
                'create table %I.%I partition of %I.%I for values from (%L) to (%L)',
                _schema, _partition, _schema, _table, _start_date, _end_date
            );
        exception when others then
            -- If partition creation fails (e.g., due to race condition), assume it’s already created
            -- and proceed with the insert. Log the error if needed for debugging.
            raise notice 'Partition % creation failed (possibly already exists): %', _partition, sqlerrm;
        end;
    end if;
end;
$$;
