create schema if not exists sys;

create or replace function sys.update_at_trigger()
returns trigger
language plpgsql
as
$$
declare
    _audit_columns text[] = TG_ARGV::text[];
begin
    if 'updated_at' = any(_audit_columns) then
        NEW.updated_at = now();
    end if;
    if 'updated_by' = any(_audit_columns) then
        if current_setting('app.user_id') is not null then
            NEW.updated_by = sys.setting('user_id')::bigint;
        end if;
    end if;
    return NEW;
end;
$$;

/*
* call sys.add_update_at_trigger(table) to create trigger that automatically updates updated_at on update
*/
create or replace procedure sys.add_update_at_trigger(
    _name regclass
)
language plpgsql
as
$$
declare 
    _schema name;
    _table name;
    _rec record;
    _columns text[];
begin
    if position('.' in _name::text) = 0 then
        _schema = 'public';
        _table = _name::text;
    else
        _schema = split_part(_name::text, '.', 1);
        _table = split_part(_name::text, '.', 2);
    end if;

    -- drop all triggers that are created by this function
    for _rec in (
        select 
            event_object_table as table_name, 
            event_object_schema table_schema,
            trigger_name as name
        from information_schema.triggers
        where 
            event_object_schema = _schema
            and event_object_table = _table
            and action_statement ilike '%sys.update_at_trigger%'
    )
    loop
        execute format('drop trigger %I on %I.%I', _rec.name, _rec.table_schema, _rec.table_name);
    end loop;

    -- get audit columns
    _columns = (
        select array_agg(column_name)
        from information_schema.columns 
        where 
            table_schema = _schema 
            and table_name = _table 
            and (column_name = 'updated_at' or column_name = 'updated_by')
    );

    if array_length (_columns, 1) is null then
        raise exception 'Table % needs an to have at least updated_at or updated_by columns!', _name;
    end if;

    execute format($sql$
        create trigger update_%s_%s_update_at
        before update on %s
        for each row
        execute function sys.update_at_trigger('%s')
    $sql$, _schema, _table, _name, array_to_string(_columns, ''', '''));
end;
$$;
