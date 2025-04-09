do
$$
begin
    if not exists (select 1 from information_schema.schemata where schema_name = 'temporal') then
        raise notice 'Creating schema temporal ...';
        create schema temporal;
    end if;

    if has_schema_privilege('${APP_USER}', 'temporal', 'USAGE') is false then
        raise notice 'Granting usage on schema temporal to ${APP_USER} ...';
        grant usage on schema temporal to ${APP_USER};
    end if;
end;
$$;
