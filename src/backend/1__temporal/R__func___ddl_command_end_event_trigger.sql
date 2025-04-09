create function temporal._ddl_command_end_event_trigger()
returns event_trigger
security definer
language plpgsql 
set search_path = public, pg_catalog
as
$$
declare
    _record record;
    _table_name text;
begin
    for _record in (
        select object_type, command_tag, schema_name, object_identity 
        from pg_catalog.pg_event_trigger_ddl_commands()
    )
    loop
        if _record.object_type = 'table' and _record.command_tag = 'ALTER TABLE' then
            _table_name = quote_ident(trim('"' from split_part(_record.object_identity, '.', 2)));
            if temporal._exists(_record.schema_name, _table_name) then
                call temporal._update_schema_history(_record.schema_name, _table_name);
            end if;
        end if;
    end loop;
end;
$$;

create event trigger ddl_command_end_event_trigger 
on ddl_command_end
when tag in ('ALTER TABLE')
execute function temporal._ddl_command_end_event_trigger();