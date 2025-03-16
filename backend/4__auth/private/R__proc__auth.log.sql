call sys.drop('auth.log');

create procedure auth.log(
    _type char(1),
    _success boolean,
    _username text,
    _message text,
    _data json
) 
language plpgsql
as 
$$
declare 
    _muted constant boolean = sys.setting('muted')::boolean;
    _timestamp timestamptz = now();
begin
    if _muted is true then
        return;
    end if;

    _message = format(_message, _username);
    raise info '%', _message;

    call sys.ensure_monthly_partition('logs', 'auth_log');

    insert into logs.auth_log (
        at,
        type,
        success,
        message,
        username,
        data
    ) values (
        _timestamp,
        _type,
        _success,
        _message,
        _username,
        _data
    );
end;
$$;
