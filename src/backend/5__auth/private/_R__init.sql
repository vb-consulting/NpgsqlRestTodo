do
$$
begin
    if not exists (select 1 from information_schema.schemata where schema_name = 'auth') then
        raise notice 'Creating schema auth ...';
        create schema auth;
    end if;

    if has_schema_privilege('${ADMIN_USER}', 'auth', 'USAGE') is false then
        raise notice 'Granting usage on schema auth to ${ADMIN_USER} ...';
        grant usage on schema auth to ${ADMIN_USER};
    end if;

    if has_schema_privilege('${APP_USER}', 'auth', 'USAGE') is false then
        raise notice 'Granting usage on schema auth to ${APP_USER} ...';
        grant usage on schema auth to ${APP_USER};
    end if;
end;
$$;
