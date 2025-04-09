create function _.schema_exists(
    _name text
)
returns boolean
language sql as
$$
select exists(
    select 1 
    from pg_catalog.pg_namespace 
    where nspname = _name
);
$$;
