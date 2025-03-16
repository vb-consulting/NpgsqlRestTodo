do
$$
begin
    if not exists (select 1 from information_schema.schemata where schema_name = 'logs') then
        raise notice 'Creating schema logs ...';
        create schema logs;
    end if;
end;
$$;
