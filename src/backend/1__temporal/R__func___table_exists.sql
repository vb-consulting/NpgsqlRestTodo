create function temporal._table_exists(
    _schema text,
    _name text
)
returns boolean
language sql 
as
$$
select exists(
    select 1 
    from information_schema.tables tbl
    join information_schema.triggers tr 
    on tbl.table_schema = tr.event_object_schema 
        and tbl.table_name = tr.event_object_table 
        and tr.trigger_name = temporal._consts('trigger_name')
    where 
        table_schema = _schema
        and table_name = _name
        and table_type = 'BASE TABLE'
    limit 1
);
$$;