create function sys.audit_update_trigger()
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
        NEW.updated_by = sys.setting('user_id')::bigint;
    end if;

    return NEW;
end;
$$;

/*
* call sys.add_audit_trigger(table) to create trigger that automatically updates updated_at and updated_by on update
* note: to update updated_by, user_id must be set in sys.setting('user_id') (see sys.settings), call sys.set_user_id(_id bigint)
*/
create procedure sys.add_audit_trigger(
    _name regclass,
    _add_missing_audit_defs boolean default true
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

    -- get fk columns
    _columns = (
        select array_agg(column_name)
        from information_schema.columns 
        where 
            table_schema = _schema and table_name = _table 
            and (
                (column_name = 'created_by'and data_type = 'bigint')
                or (column_name = 'updated_by'and data_type = 'bigint')
            )
    );

    if _add_missing_audit_defs and 'created_by' = any(_columns) then
        if not exists(
            select 1 
            from pg_constraint 
            where conrelid = _name 
            and pg_get_constraintdef(oid, true) = 'FOREIGN KEY (created_by) REFERENCES auth_users(user_id) ON DELETE SET NULL DEFERRABLE'
        ) then
            execute format($sql$
                alter table only %s
                add foreign key (created_by) 
                references public.auth_users(user_id) 
                on delete set null deferrable initially immediate
            $sql$, _name);
        end if;

        if exists(
            select 1
            from information_schema.columns 
            where 
                table_schema = _schema and table_name = _table and column_name = 'created_by' and column_default is null
        ) then
            execute format($sql$
                alter table %s
                alter column created_by 
                set default sys.setting('user_id')::bigint;
            $sql$, _name);
        end if;
    end if;

    if _add_missing_audit_defs and 'updated_by' = any(_columns) then
        if not exists(
            select 1 
            from pg_constraint 
            where conrelid = _name 
            and pg_get_constraintdef(oid, true) = 'FOREIGN KEY (updated_by) REFERENCES auth_users(user_id) ON DELETE SET NULL DEFERRABLE'
        ) then
            execute format($sql$
                alter table only %s
                add foreign key (updated_by) 
                references public.auth_users(user_id) 
                on delete set null deferrable initially immediate
            $sql$, _name);
        end if;

        if exists(
            select 1
            from information_schema.columns 
            where 
                table_schema = _schema and table_name = _table and column_name = 'updated_by' and column_default is null
        ) then
            execute format($sql$
                alter table %s
                alter column updated_by 
                set default sys.setting('user_id')::bigint;
            $sql$, _name);
        end if;
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
            and action_statement ilike '%sys.audit_update_trigger%'
    )
    loop
        execute format('drop trigger %I on %I.%I', _rec.name, _rec.table_schema, _rec.table_name);
    end loop;

    -- get audit columns
    _columns = (
        select array_agg(column_name)
        from information_schema.columns 
        where 
            table_schema = _schema and table_name = _table 
            and (
                (column_name = 'updated_at' and udt_name = 'timestamp without time zone') 
                or (column_name = 'updated_by'and data_type = 'bigint')
            )
    );

    if array_length(_columns, 1) is null then
        raise exception 'Table % needs an to have at least updated_at or updated_by columns!', _name;
    end if;

    execute format($sql$
        create trigger update_%s_%s_update_at
        before update on %s
        for each row
        execute function sys.audit_update_trigger('%s')
    $sql$, _schema, _table, _name, array_to_string(_columns, ''', '''));
end;
$$;
