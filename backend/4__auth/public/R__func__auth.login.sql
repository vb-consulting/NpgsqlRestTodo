call sys.drop('auth.create_login_response');
call sys.drop('auth.login');
drop type if exists auth.login_response;

-- Create a type to represent the response of the login function.
create type auth.login_response as (
    status int,
    scheme text,
    name_identifier text, 
    name text,
    role text[],
    message json
);

-- Create a factory function to create the login response type.
create function auth.create_login_response(
    _log_message text,
    _name text,
    _data json,
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
    call auth.log(_type => 'I', _success => _success, _username => _name, _message => _log_message, _data => _data);
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

-- login function
create function auth.login(
    _username text,
    _password text,
    _data json = '{}',
    _ip_address text = null
)
returns auth.login_response
security definer
language plpgsql
as
$$
declare
    _record record;
    _attempt int;
    _algorithm constant text = auth.setting('algorithm');
    _max_attempts constant int = auth.setting('max_attempts')::int;
    _lockout_interval constant interval = auth.setting('lockout_interval')::interval;
    _now constant timestamptz = sys.setting('now')::timestamptz;
begin 
    _data = coalesce(
        jsonb_set(_data::jsonb, '{ip}', to_jsonb(_ip_address))::json, 
        '{}'::json);

    if sys.validate_email(_username) is false then
        return auth.create_login_response('Invalid email in logging attempt. %s', _username, _data);
    end if;

    select 
        u.user_id, u.email, u.expires_at, u.active_after, u.confirmed, u.password_hash, 
        array_agg(r.name) as roles
    into _record
    from auth_users u 
    left join auth_users_roles ur using(user_id)
    join auth_roles r using (role_id)
    where 
        u.email = _username
    group by 
        u.user_id, u.email, u.expires_at, u.active_after, u.confirmed, u.password_hash;

    if _record is null then
        return auth.create_login_response('User does not exist in logging attempt. %s', _username, _data);
    end if;

    if _record.expires_at is not null and _record.expires_at < _now then
        return auth.create_login_response('User is expired in logging attempt. %s', _username, _data);
    end if;

    if _record.active_after is not null and _record.active_after > _now then
        return auth.create_login_response('User is not active in logging attempt. %s', _username, _data);
    end if;

    if _record.confirmed is false then
        return auth.create_login_response('User is not confirmed in logging attempt. %s', _username, _data);
    end if;

    if _record.password_hash is null then
        return auth.create_login_response('User does not have a password in logging attempt. %s', _username, _data);
    end if;

    if crypt(_password, _record.password_hash) <> _record.password_hash then
        update auth_users
        set password_attempts = password_attempts + 1
        where user_id = _record.user_id
        returning password_attempts into _attempt;

        if _attempt >= _max_attempts then
            update auth_users
            set active_after = _now + _lockout_interval
            where user_id = _record.user_id;

            return auth.create_login_response('User %s is locked out in logging attempt', _username, _data);
        end if;

        return auth.create_login_response('Invalid password in logging attempt. %s', _username, _data);
    end if;

    update auth_users
    set 
        password_attempts = 0,
        password_hash = crypt(_password, gen_salt(_algorithm)),
        last_login_at = _now,
        last_login_data = _data
    where 
        user_id = _record.user_id;

    return auth.create_login_response(
        _log_message => 'User %s logged in.',
        _data => _data,
        _success => true,
        _name_identifier => _record.user_id::text,
        _name => _username,
        _role => _record.roles,
        _message => json_build_object(
            'id', _record.user_id::text, 
            'name', _record.email, 
            'roles', _record.roles
        )
    );
end
$$;

call sys.annotate('auth.login', 
    'HTTP POST', 
    'Login',
    'Anonymous'
);
