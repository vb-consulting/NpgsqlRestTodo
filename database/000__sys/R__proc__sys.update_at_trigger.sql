do
$$
declare
    _rec record;
begin
    for _rec in (
        select 
            event_object_table as table_name, 
            event_object_schema table_schema,
            trigger_name as name
        from information_schema.triggers
        where action_statement ilike '%sys.update_at_trigger%'
    )
    loop
        execute format('drop trigger %I on %I.%I', _rec.name, _rec.table_schema, _rec.table_name);
    end loop;
end;
$$;

call sys.drop('sys.update_at_trigger');

create function sys.update_at_trigger()
returns trigger
language plpgsql
as
$$
begin
    NEW.updated_at = now();
    return NEW;
end;
$$;

call sys.drop('sys.add_update_at_trigger');
/*
* call sys.add_update_at_trigger(table) to create trigger that automatically updates updated_at on update
*/
create procedure sys.add_update_at_trigger(
    _name regclass
)
language plpgsql
as
$$
declare 
    _schema name;
    _table name;
begin
    if position('.' in _name::text) = 0 then
        _schema = 'public';
        _table = _name::text;
    else
        _schema = split_part(_name::text, '.', 1);
        _table = split_part(_name::text, '.', 2);
    end if;

    if not exists (
        select 1 
        from information_schema.columns 
        where table_schema = _schema 
        and table_name = _table 
        and column_name = 'updated_at'
    ) then
        raise exception 'Table % needs an updated_at column!', _name;
    end if;

    execute format($sql$
        create trigger update_%s_%s_update_at
        before update on %s
        for each row
        execute function sys.update_at_trigger()
    $sql$, _schema, _table, _name);
end;
$$;
