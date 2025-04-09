create procedure temporal._update_schema_history(
    _schema text,
    _table text
)
language plpgsql 
set search_path = public, pg_catalog
as
$$
declare
    _record record;
    _history_schema text;
    _schema_table text;
    _schema_data text[];

    _history_schema_suffix constant text = temporal._consts('history_schema_suffix');
    _schema_table_suffix constant text = temporal._consts('schema_table_suffix');
begin
    _history_schema = quote_ident(_schema || _history_schema_suffix);
    _schema_table = quote_ident(_table || _schema_table_suffix);

    execute format(
        $sql$
        select * 
        from %1$I.%2$I 
        where schema_id = (
            select max(schema_id) from %1$I.%2$I
        );
        $sql$,
        _history_schema, _schema_table
    ) into _record;

    _schema_data = (
        select
            array_agg(
                trim(concat(
                    quote_ident(c.column_name),
                    ' ',
                    (c.udt_schema || '.' || c.udt_name)::regtype::text,
                    ' ',
                    case when c.is_nullable = 'NO' then 'NOT NULL ' else '' end, 
                    case
                        when c.is_generated <> 'NEVER' then 'GENERATED ' || c.is_generated || ' AS ' || c.generation_expression
                        when c.column_default is not null then 'DEFAULT ' || c.column_default
                    end
                )) order by c.ordinal_position
            )
        from 
            information_schema.columns c
        where
            c.table_schema = _schema
            and c.table_name = _table
    );

    if _record.data = _schema_data then
        return;
    end if;

    execute format(
        $sql$
        insert into %1$I.%2$I (data) 
        values ($1);
        $sql$,
        _history_schema, _schema_table
    ) using _schema_data;
end;
$$;