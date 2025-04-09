create function temporal._consts(
    _key text
)
returns text
language sql
immutable
parallel safe
as
$$
select case _key
    when 'trigger_function_name' then 'temporal._temporal_table_after_trigger'
    when 'trigger_name' then 'temporal_table_after_delete_or_update_trigger'
    when 'history_schema_suffix' then '_history'
    when 'schema_table_suffix' then '_schema_history'
    else null
end;
$$;