call _.drop('app.log');

/*
Log procedure called by the structured application logging mechanism.

See npgsqlrest.json:
"Log": {
    //...
    "ToPostgres": true,
    // $1 - log level text, $2 - message text, $3 - timestamp with tz in utc, $4 - exception text or null, $5 - source context
    "PostgresCommand": "call app.log($1,$2,$3,$4,$5)",
    "PostgresMinimumLevel": "Warning"
}
*/
create procedure app.log(
    _level text,
    _message text,
    _log_timestamp timestamptz,
    _exception text,
    _context text
) 
language plpgsql
security definer
as 
$$
begin
    if _log_timestamp is null then
        _log_timestamp = clock_timestamp();
    end if;
    insert into logs.app_log (
        at,
        level,
        message,
        exception,
        context
    ) values (
        _log_timestamp,
        case 
            when _level::char(1) = 'V' then 'VRB'
            when _level::char(1) = 'D' then 'DBG'
            when _level::char(1) = 'I' then 'INF'
            when _level::char(1) = 'W' then 'WRN'
            when _level::char(1) = 'E' then 'ERR'
            when _level::char(1) = 'F' then 'FTL'
            else 'INF'
        end,
        _message,
        _exception,
        _context
    );
end;
$$;
