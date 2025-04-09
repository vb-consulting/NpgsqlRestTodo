do
$$
begin
    if not exists (select 1 from information_schema.schemata where schema_name = 'app') then
        raise notice 'Creating schema app ...';
        create schema app;
    end if;

    if has_schema_privilege('${ADMIN_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${ADMIN_USER} ...';
        grant usage on schema app to ${ADMIN_USER};
    end if;

    if has_schema_privilege('${APP_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${APP_USER} ...';
        grant usage on schema app to ${APP_USER};
    end if;

    if has_schema_privilege('${WORKER_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${WORKER_USER} ...';
        grant usage on schema app to ${WORKER_USER};
    end if;

    if has_schema_privilege('${PGBOUNCER_USER}', 'app', 'USAGE') is false then
        raise notice 'Granting usage on schema app to ${PGBOUNCER_USER} ...';
        grant usage on schema app to ${PGBOUNCER_USER};
    end if;
end;
$$;
