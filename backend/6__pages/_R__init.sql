do
$$
begin
    if not exists (select 1 from information_schema.schemata where schema_name = 'pages') then
        raise notice 'Creating schema pages ...';
        create schema pages;
    end if;

    if has_schema_privilege('${APP_USER}', 'pages', 'USAGE') is false then
        raise notice 'Granting usage on schema pages to ${APP_USER} ...';
        grant usage on schema pages to ${APP_USER};
    end if;
end;
$$;
