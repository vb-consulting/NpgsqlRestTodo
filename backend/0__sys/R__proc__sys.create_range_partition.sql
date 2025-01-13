call sys.drop('sys.create_range_partition');
/*
Ensures that partition is created for the table name from arguments.
Monthly partitions will be in format schema.table_YYYYMM (e.g. logs.auth_log_202503)
Daily partition will be in format schema.table_YYYYMMDD (e.g. auth_email_confirmations_20250321)
*/
create procedure sys.create_range_partition(
    _name regclass,
    _timestamp timestamptz = now(),
    _monthly boolean = true -- If false, daily partition will be created
) 
language plpgsql
as 
$$
declare 
    _schema name;
    _table name;
    _partition text;
    _start_date timestamptz;
    _end_date timestamptz;
begin
    -- Split table name into schema and table
    if position('.' in _name::text) = 0 then
        _schema = 'public';
        _table = _name::text;
    else
        _schema = split_part(_name::text, '.', 1);
        _table = split_part(_name::text, '.', 2);
    end if;
    
    -- Set partition name based on monthly/daily
    if _monthly then
        _partition = _table || '_' || to_char(_timestamp, 'YYYYMM');
        _start_date = date_trunc('month', _timestamp);
        _end_date = _start_date + interval '1 month';
    else
        _partition = _table || '_' || to_char(_timestamp, 'YYYYMMDD');
        _start_date = date_trunc('day', _timestamp);
        _end_date = _start_date + interval '1 day';
    end if;

    -- Create partition if it doesn't exist
    if not exists (
        select 1 from information_schema.tables
        where table_schema = _schema 
        and table_name = _partition
    ) then
        begin
            execute format(
                'create table %I.%I partition of %I.%I for values from (%L) to (%L)',
                _schema, _partition, _schema, _table, _start_date, _end_date
            );
        exception when others then
            -- Log if partition creation fails (might already exist)
            raise notice 'Partition % creation failed (possibly already exists): %', _partition, sqlerrm;
        end;
    end if;
end;
$$;
