create function _.table_exists(
    _schema text,
    _name text
)
returns boolean
language sql as
$$
select exists(
    select 1 
    from information_schema.tables 
    where 
        table_schema = _schema
        and table_name = _name
        and table_type = 'BASE TABLE'
);
$$;
