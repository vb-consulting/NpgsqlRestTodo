call sys.drop('auth.register');

create function auth.register(
    _email text,
    _password text,
    _repeat text,

    _analytics_data jsonb = '{}',
    _ip_address text = null
)
returns auth.register_response
security definer
language plpgsql
as
$$
declare
    _existing record;
    _default_roles constant text[] = auth.setting('default_roles')::text[];
    _require_email_confirmation constant boolean = auth.setting('require_email_confirmation')::boolean;
    _created_user_id bigint;
    _validate_response auth.register_response;
    _log_type constant text = 'register';
begin 
    _analytics_data = sys.add_jsonb_key(_analytics_data, 'ip', _ip_address);

    if sys.validate_email(_email) is false then
        return auth.create_register_response(
            1, 'Invalid email.', _email, _analytics_data
        );
    end if;

    _validate_response = auth.validate_password(_email, _password, _repeat, _analytics_data, _log_type);
    if _validate_response.code is not null then
        return _validate_response;
    end if;

    select user_id, email, password_confirmed 
    into _existing 
    from auth_users 
    where email = _email;

    if _existing is not null then
        return auth.create_register_response(10, 'Success.', _email, _analytics_data, _log_type);
    end if;

    insert into auth_users (
        email, 
        password_hash, 
        password_confirmed
    ) 
    values (
        _email, 
        sys.hash(_password),
        case when _require_email_confirmation is true then false else true end
    )
    on conflict (email) do nothing
    returning user_id into _created_user_id;

    if _created_user_id is null then
        return auth.create_register_response(
            10, 'Success.', _email, _analytics_data
        );
    end if;

    insert into auth_users_roles
        (user_id, role_id)
    select
        _created_user_id,
        r.role_id
    from auth_roles r
    where r.name = any(_default_roles);

    if _require_email_confirmation is true then
        call auth.add_email_confirmation(_email, _created_user_id, _analytics_data);
    end if;

    return auth.create_register_response(0, 'Success.', _email, _analytics_data, _log_type);
end
$$;

call sys.annotate('auth.register', 
    'HTTP POST', 
    'Anonymous',
    'SecuritySensitive'
);
