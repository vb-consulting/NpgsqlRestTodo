create function temporal._sql_drop_event_trigger()
returns event_trigger
security definer
language plpgsql 
set search_path = public, pg_catalog
as
$$
declare
    _record record;
    _schema text;
    _history_schema text;
    _schema_table_name text;

    _history_schema_suffix constant text = temporal._consts('history_schema_suffix');
    _schema_table_suffix constant text = temporal._consts('schema_table_suffix');
begin
    for _record in (
        select object_type, schema_name, object_name 
        from pg_catalog.pg_event_trigger_dropped_objects()
    )
    loop
        if _record.object_type = 'table' then

            if _record.schema_name like '%' || _history_schema_suffix then -- table is in history schema
                _schema = split_part(_record.schema_name, _history_schema_suffix, 1);
                if temporal._table_exists(_schema, _record.object_name) then
                    -- prevent dropping table with active history
                    raise exception 'Cannot drop active history for table %.%', _schema, _record.object_name;
                end if;
            else -- normal table
                -- delete any history table still remaining

                _history_schema = _record.schema_name || _history_schema_suffix;
                if _.table_exists(_history_schema, _record.object_name) then 
                    call _.exec(
                        $sql$
                        drop table if exists %history_schema$I.%table_name$I;
                        $sql$, 
                        'history_schema', _history_schema,
                        'table_name', _record.object_name
                    );
                end if; 
                _schema_table_name = _record.object_name || _schema_table_suffix;
                if _.table_exists(_history_schema, _schema_table_name) then 
                    call _.exec(
                        $sql$
                        drop table if exists %history_schema$I.%schema_table_name$I;
                        $sql$, 
                        'history_schema', _history_schema,
                        'schema_table_name', _schema_table_name
                    );
                end if; 

            end if; -- end table is in history schema
        end if; -- end table
    end loop;
end;
$$;

create event trigger sql_drop_event_trigger 
on sql_drop 
execute function temporal._sql_drop_event_trigger();