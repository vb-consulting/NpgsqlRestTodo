create function temporal._temporal_table_after_trigger()
returns trigger
security definer
language plpgsql 
as
$$
declare
    _history_schema text;
    _table text;
    _schema_table text;

    _history_schema_suffix constant text = temporal._consts('history_schema_suffix');
    _schema_table_suffix constant text = temporal._consts('schema_table_suffix');
begin
    _history_schema = quote_ident(TG_ARGV[0] || _history_schema_suffix);
    _table = TG_ARGV[1];
    _schema_table = quote_ident(_table || _schema_table_suffix);

    execute format(
        $sql$
        insert into %1$I.%2$I (data, schema_id) 
        select $1, (select max(schema_id) from %1$I.%3$I);
        $sql$, 
        _history_schema, _table, _schema_table
    ) using row_to_json(old.*);

    return null;
end;
$$;