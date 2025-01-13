call sys.drop('auth.create_register_response');

create function auth.create_register_response(
    _code int,
    _message text,
    _email text,
    _analytics_data jsonb = '{}'
)
returns auth.register_response
language plpgsql
as
$$
begin
    call auth.log_register(_success => _code = 0, _username => _email, _message => _message, _analytics_data => _analytics_data);
    return (_code, _message)::auth.register_response;
end
$$;