call _.drop('auth.register');

create function auth.register(
    _email text,
    _password text,
    _repeat text,
    _analytics jsonb = '{}',
    _hash text = null
)
returns auth.register_response
security definer
language plpgsql
set search_path = public, pg_catalog
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
    _analytics = _.append_ip_address(_analytics);

    if _.validate_email(_email) is false then
        call auth.log(_log_type, false, _email, 'Invalid email while attempting to register.', _analytics);
        return auth.create_register_response(1, 'Invalid email.');
    end if;

    _validate_response = auth.validate_password(_email, _password, _repeat, _analytics, _log_type);
    if _validate_response.code is not null then
        call auth.log(_log_type, false, _email, 'Invalid password while attempting to register: ' || _validate_response.message, _analytics);
        return _validate_response;
    end if;

    select user_id, email, password_confirmed 
    into _existing 
    from public.auth_users 
    where email = _email;

    if _existing is not null then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _existing.user_id);
        call auth.log(_log_type, true, _email, 'User that already exists attempting to register.', _analytics);
        return auth.create_register_response(10, null);
    end if;

    insert into public.auth_users (
        email, 
        password_hash, 
        password_confirmed
    ) 
    values (
        _email, 
        _hash,
        case when _require_email_confirmation is true then false else true end
    )
    on conflict (email) do nothing
    returning user_id into _created_user_id;

    _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _created_user_id);
    if _created_user_id is null then
        call auth.log(_log_type, true, _email, 'User that already exists attempting to register.', _analytics);
        return auth.create_register_response(10, null);
    end if;

    insert into public.auth_users_roles
        (user_id, role_id)
    select
        _created_user_id,
        r.role_id
    from public.auth_roles r
    where r.name = any(_default_roles);

    if _require_email_confirmation is true then
        call auth.add_email_confirmation(_email, _created_user_id, _analytics);
    end if;

    call auth.log(_log_type, true, _email, 'Success register of new user.', _analytics);
    return auth.create_register_response(0, null);
end
$$;

call _.annotate('auth.register', 
    'HTTP POST', 
    'anonymous',
    'security_sensitive',
    'parameter _hash is hash of _password'
);
