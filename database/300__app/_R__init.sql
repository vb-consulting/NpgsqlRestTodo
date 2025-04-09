do
$$
begin
    if not exists (select 1 from pg_roles where rolname = '${WORKER_USER}') then
        raise notice 'Creating app role ...';
        create role ${WORKER_USER} with
            login
            nosuperuser
            nocreatedb
            nocreaterole
            noinherit
            noreplication
            connection limit -1
            password '${WORKER_PASSWORD}';
    end if;

    if not exists (select 1 from information_schema.schemata where schema_name = 'app') then
        raise notice 'Creating schema app ...';
        create schema app;
    end if;

    if has_schema_privilege('${APP_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${APP_USER} ...';
        grant usage on schema app to ${APP_USER};
    end if;

    if has_schema_privilege('${WORKER_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${WORKER_USER} ...';
        grant usage on schema app to ${WORKER_USER};
    end if;
end;
$$;
