call sys.drop('auth.log_login');
call sys.drop('auth.log_logout');
call sys.drop('auth.log_register');
call sys.drop('auth.log_code');
call sys.drop('auth.log');

create procedure auth.log(
    _type char(1),
    _success boolean,
    _username text,
    _message text,
    _analytics_data jsonb
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

    call sys.create_range_partition(_name => 'logs.auth_log', _timestamp => _timestamp, _monthly => true);

    insert into logs.auth_log (
        at,
        type,
        success,
        message,
        username,
        analytics_data
    ) values (
        _timestamp,
        _type,
        _success,
        _message,
        _username,
        _analytics_data
    );
end;
$$;

create procedure auth.log_login(
    _success boolean,
    _username text,
    _message text,
    _analytics_data jsonb
) 
language sql as 
$$call auth.log('login', _success, _username, _message, _analytics_data);$$;

create procedure auth.log_logout(
    _success boolean,
    _username text,
    _message text,
    _analytics_data jsonb
) 
language sql as 
$$call auth.log('logout', _success, _username, _message, _analytics_data);$$;

create procedure auth.log_register(
    _success boolean,
    _username text,
    _message text,
    _analytics_data jsonb
) 
language sql as 
$$call auth.log('register', _success, _username, _message, _analytics_data);$$;

create procedure auth.log_code(
    _success boolean,
    _username text,
    _message text,
    _analytics_data jsonb
) 
language sql as 
$$call auth.log('code', _success, _username, _message, _analytics_data);$$;