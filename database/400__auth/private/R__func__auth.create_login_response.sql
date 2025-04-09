call sys.drop('auth.create_login_response');

create function auth.create_login_response(
    _type text,
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
    if _type in ('login', 'confirm_email', 'external_login') is false then
        raise exception 'Invalid type %', _type;
    end if;

    call auth.log(
        _type, 
        _success, 
        _name, 
        _log_message, 
        _analytics_data
    );
    return row(
        case when _success is true then 200 else 404 end, 
        case when _success is true then _scheme else null end,
        case when _success is true then _name_identifier else null end,
        case when _success is true then _name else null end,
        case when _success is true then _role else null end,
        case when _success is true then _message else null end
    )::auth.login_response;
end
$$;

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
language sql
as
$$
select r::auth.login_response 
from auth.create_login_response(
    'login', 
    _log_message, 
    _name, 
    _analytics_data, 
    _success, 
    _name_identifier, 
    _role, 
    _message
) r
$$;
