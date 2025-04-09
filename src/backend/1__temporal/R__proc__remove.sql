/*
Deinitializes (removes) temporal support for argument tables
*/
create procedure temporal.remove(
    _drop_history boolean,
    variadic _tables regclass[]
)
security definer
language plpgsql 
set search_path = public, pg_catalog
as
$$
declare
    _record record;
    _history_schema text;
    _schema_table text;

    _trigger_name constant text = temporal._consts('trigger_name');
    _history_schema_suffix constant text = temporal._consts('history_schema_suffix');
    _schema_table_suffix constant text = temporal._consts('schema_table_suffix');
begin
    for _record in (
        select distinct table_schema, table_name 
        from 
            information_schema.tables tbl
            join information_schema.triggers tr 
            on tbl.table_schema = tr.event_object_schema and tbl.table_name = tr.event_object_table and tr.trigger_name = _trigger_name
        where
            (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass = any(_tables)
            and table_type = 'BASE TABLE'
    )
    loop
        _history_schema = quote_ident(_record.table_schema || _history_schema_suffix);

        -- remove trigger
        call _.exec(
            $sql$
            drop trigger if exists %trigger_name$I 
            on %table_schema$I.%table_name$I;
            $sql$, 
            'trigger_name', _trigger_name,
            'table_schema', _record.table_schema,
            'table_name', _record.table_name
        );

        if _drop_history is true then
            -- remove history table
            _schema_table = quote_ident(_record.table_name || _schema_table_suffix);
            call _.exec(
                $sql$
                drop table if exists %history_schema$I.%table_name$I;
                drop table if exists %history_schema$I.%schema_table_name$I;
                $sql$, 
                'history_schema', _history_schema,
                'table_name', _record.table_name,
                'schema_table_name', _schema_table
            );
        end if;
    end loop;
end;
$$;
