/*
Initializes temporal support for argument tables
*/
create procedure temporal.init(
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

    _trigger_func constant text = temporal._consts('trigger_function_name');
    _trigger_name constant text = temporal._consts('trigger_name');
    _history_schema_suffix constant text = temporal._consts('history_schema_suffix');
    _schema_table_suffix constant text = temporal._consts('schema_table_suffix');
begin
    for _record in (
        select table_schema, table_name 
        from 
            information_schema.tables tbl
            left join information_schema.triggers tr 
            on tbl.table_schema = tr.event_object_schema and tbl.table_name = tr.event_object_table and tr.trigger_name = _trigger_name
        where 
            -- filter out tables that already have trigger
            tr.event_object_table is null
            and (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass = any(_tables)
            and table_type = 'BASE TABLE'
    )
    loop
        _history_schema = quote_ident(_record.table_schema || _history_schema_suffix);
        _schema_table = quote_ident(_record.table_name || _schema_table_suffix);

        if not _.schema_exists(_history_schema) then
            call _.exec('create schema %history_schema$I', 
                'history_schema', _history_schema
            );
        end if;

        if not _.table_exists(_history_schema, _schema_table) then
            call _.exec(
                $sql$
                create table %history_schema$I.%schema_table_name$I (
                    schema_id int not null generated always as identity primary key,
                    data text[] not null,
                    timestamp timestamptz not null default now()
                );
                create trigger temporal_history_before_trigger 
                before delete or update on %history_schema$I.%schema_table_name$I 
                for each row execute function temporal._temporal_history_before_trigger();
                $sql$,
                'history_schema', _history_schema,
                'schema_table_name', _schema_table
            );
        end if;

        if not _.table_exists(_history_schema, _record.table_name) then
            call _.exec(
                $sql$
                create table %history_schema$I.%table_name$I (
                    id bigint generated always as identity primary key,
                    clock_ts timestamptz not null default clock_timestamp(),
                    tran_ts timestamptz not null default now(),
                    data jsonb not null,
                    schema_id int not null references %history_schema$I.%schema_table_name$I(schema_id)
                );
                create trigger temporal_history_before_trigger 
                before delete or update on %history_schema$I.%table_name$I 
                for each row execute function temporal._temporal_history_before_trigger('%history_schema$I', '%table_name$I');
                $sql$,
                'history_schema', _history_schema,
                'table_name', _record.table_name,
                'schema_table_name', _schema_table
            );
        end if;

        call _.exec(
            $sql$
            create trigger %trigger_name$I 
            after delete or update 
            on %table_schema$I.%table_name$I
            for each row execute function %trigger_function_name$s('%table_schema$I', '%table_name$I');
            $sql$, 
            'trigger_name', _trigger_name, 
            'trigger_function_name', _trigger_func, 
            'table_schema', _record.table_schema,
            'table_name', _record.table_name
        );

        call temporal._update_schema_history(_record.table_schema, _record.table_name);
    end loop;
end;
$$;
