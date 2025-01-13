call sys.drop('auth.confirm_email_code');

create function auth.confirm_email_code(
    _code text,
    _email text,
    _analytics_data jsonb = '{}',
    _ip_address text = null
)
returns auth.login_response
security definer
language plpgsql
as
$$
declare
    _record record;
    _user_id bigint;
    _now constant timestamptz = sys.setting('now')::timestamptz;
    _algorithm constant text = auth.setting('algorithm');
    _expires_interval constant interval = auth.setting('email_confirmation_expires_in')::interval;
begin 
    _analytics_data = sys.add_jsonb_key(_analytics_data, 'ip', _ip_address);

    select
        user_id, expires_at, confirmed_at
    into _record
    from auth_email_confirmations 
    where 
        created_at >= _now - _expires_interval and code = _code
    order by created_at desc
    limit 1;

    if _record is null then
        return auth.create_login_response('Email confirmation code could not be located within expiration interval ' || _expires_interval::text, _email, _analytics_data);
    end if;

    if _record.expires_at < _now then
        return auth.create_login_response('Email confirmation code has expired.', _email, _analytics_data);
    end if;

    if _record.confirmed_at is not null then
        return auth.create_login_response('Email confirmation code has already been used.', _email, _analytics_data);
    end if;

    update auth_users
    set 
        password_attempts = 0,
        last_login_at = _now,
        confirmed = true,
        analytics_data = _analytics_data
    where 
        user_id = _record.user_id
    returning user_id into _user_id;

    if _user_id is null then
        return auth.create_login_response('User could not be updated. Invalid user_id=' || _record.user_id::text, _email, _analytics_data);
    end if;

    update auth_email_confirmations
    set 
        confirmed_at = _now
    where 
        user_id = _user_id and code = _code;

    select 
        u.user_id, u.email, u.expires_at, u.active_after,
        array_agg(r.name) as roles
    into _record
    from auth_users u 
    left join auth_users_roles ur using(user_id)
    join auth_roles r using (role_id)
    where 
        u.user_id = _user_id
    group by 
        u.user_id, u.email, u.expires_at, u.active_after;

    if _record.expires_at is not null and _record.expires_at < _now then
        return auth.create_login_response('User is expired in logging attempt. %s', _record.email, _analytics_data);
    end if;

    if _record.active_after is not null and _record.active_after > _now then
        return auth.create_login_response('User is not active in logging attempt. %s', _record.email, _analytics_data);
    end if;

    return auth.create_login_response(
        _log_message => 'User %s logged in.',
        _analytics_data => _analytics_data,
        _success => true,
        _name_identifier => _record.user_id::text,
        _name => _record.email,
        _role => _record.roles,
        _message => json_build_object(
            'id', _record.user_id::text, 
            'name', _record.email, 
            'roles', _record.roles
        )
    );
end;
$$;

call sys.annotate('auth.confirm_email_code', 
    'HTTP POST', 
    'Anonymous',
    'Login'
);
