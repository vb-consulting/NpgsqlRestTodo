create function temporal._exists(
    _schema text,
    _name text
)
returns boolean
language sql 
as
$$
select exists(
    select 1 
    from information_schema.triggers
    where 
        event_object_schema = _schema
        and event_object_table = _name
        and trigger_name = temporal._consts('trigger_name')
    limit 1
);
$$;