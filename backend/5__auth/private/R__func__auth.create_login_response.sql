call sys.drop('auth.create_login_response');

create function auth.create_login_response(
    _log_message text,
    _name text,
    _analytics_data jsonb,
    _success boolean = false,
    _name_identifier text = null,
    _role text[] = null,
    _message json = null
)
returns auth.login_response
language plpgsql
as
$$
declare
    _scheme constant text = auth.setting('default_scheme');
begin
    call auth.log_login(_success, _name, _log_message, _analytics_data);
    return row(
        case when _success is true then 200 else 404 end, 
        _scheme, 
        _name_identifier, 
        _name, 
        _role, 
        _message
    )::auth.login_response;
end
$$;
