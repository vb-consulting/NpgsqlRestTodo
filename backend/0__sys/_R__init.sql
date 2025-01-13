/*
Format placeholders like ${APP_USER} and ${APP_PASSWORD} are injected from the environment variables by pgmigrations.
*/
do
$$
begin
    if not exists (select 1 from pg_roles where rolname = '${APP_USER}') then
        raise notice 'Creating ${APP_USER} role ...';
        create role ${APP_USER} with
            login
            nosuperuser
            nocreatedb
            nocreaterole
            noinherit
            noreplication
            connection limit -1
            password '${APP_PASSWORD}';
    end if;

    if not exists (select 1 from pg_extension where extname = 'pgcrypto') then
        raise notice 'Creating extension pgcrypto ...';
        create extension pgcrypto;
    end if;

    if not exists (select 1 from pg_extension where extname = 'pg_stat_statements') then
        raise notice 'Creating extension pg_stat_statements ...';
        create extension pg_stat_statements;
    end if;

    if not exists (select 1 from information_schema.schemata where schema_name = 'sys') then
        raise notice 'Creating schema sys ...';
        create schema sys;
    end if;
end;
$$;
