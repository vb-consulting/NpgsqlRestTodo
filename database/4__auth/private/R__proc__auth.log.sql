call _.drop('auth.log');

create procedure auth.log(
    _type char(1),
    _success boolean,
    _username text,
    _message text,
    _analytics jsonb
) 
language plpgsql
as 
$$
declare 
    _muted constant boolean = _.setting('muted')::boolean;
begin
    if _muted is true then
        return;
    end if;

    _message = format(_message, _username);
    raise info '%', _message;

    insert into logs.auth_log (
        type,
        success,
        message,
        username,
        analytics
    ) values (
        _type,
        _success,
        _message,
        _username,
        _analytics
    );
end;
$$;
