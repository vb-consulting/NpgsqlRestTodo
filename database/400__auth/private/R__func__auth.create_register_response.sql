call sys.drop('auth.create_register_response');

create function auth.create_register_response(
    _code int,
    _message text,
    _email text,
    _analytics_data jsonb = '{}',
    _log_type text = 'register'
)
returns auth.register_response
language plpgsql
as
$$
begin
    if _log_type in ('register', 'password_reset') is false then
        raise exception 'Invalid type %', _type;
    end if;
    call auth.log(
        _log_type, 
        _code = 0,
        _email, 
        _message, 
        _analytics_data
    );
    return (_code, _message)::auth.register_response;
end
$$;