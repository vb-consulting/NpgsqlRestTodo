call _.drop('auth.login');

create function auth.login(
    _username text,
    _password text,
    _analytics jsonb = '{}'
)
returns auth.login_response
security definer
language plpgsql
set search_path = public, pg_catalog
as
$$
declare
    _record record;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _log_type constant text = 'login';
begin 
    raise info '_username: %', _username;
    raise info '_password: %', _password;
    raise info '_analytics: %', _analytics;

    _analytics = _.append_ip_address(_analytics);
    if _.validate_email(_username) is false then
        call auth.log(_log_type, false, _username, 'Invalid email in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    select 
        u.user_id, 
        u.email, 
        u.expires_at, 
        u.active_after, 
        u.password_confirmed, 
        u.password_hash, 
        array_agg(r.name) as roles
    into _record
    from public.auth_users u 
    left join public.auth_users_roles ur using(user_id)
    join public.auth_roles r using (role_id)
    where 
        u.email = _username
    group by 
        u.user_id, u.email, u.expires_at, u.active_after, u.password_confirmed, u.password_hash;

    if _record is null then
        call auth.log(_log_type, false, _username, 'User does not exist in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.expires_at is not null and _record.expires_at < _now then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id, 'expires_at', _record.expires_at);
        call auth.log(_log_type, false, _username, 'User is expired in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.active_after is not null and _record.active_after > _now then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id, 'active_after', _record.active_after);
        call auth.log(_log_type, false, _username, 'User is not active in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.password_confirmed is false then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id);
        call auth.log(_log_type, false, _username, 'User is not confirmed in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.password_hash is null then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id);
        call auth.log(_log_type, false, _username, 'User does not have a password in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id);
    call auth.log(_log_type, true, _username, 'User is attempting login.', _analytics);

    return auth.create_login_response(
        true, 
        _record.user_id, 
        _username, 
        _record.roles,
        _record.password_hash
    );
end
$$;

call _.annotate('auth.login', 
    'HTTP POST', 
    'login',
    'anonymous'
);
