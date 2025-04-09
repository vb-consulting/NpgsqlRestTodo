call _.drop('auth.confirm_email');

create function auth.confirm_email(
    _code text,
    _email text,
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
    _user_id bigint;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _algorithm constant text = auth.setting('algorithm');
    _log_type constant text = 'confirm_email';
begin 
    _analytics = _.append_ip_address(_analytics);
    select
        user_id, confirmed_at
    into _record
    from public.auth_email_confirmations 
    where 
        expires_at > _now and code = _code
    order by expires_at desc
    limit 1;

    if _record is null then
        call auth.log(_log_type, false, _email, 'Email confirmation code could not be located within expiration interval.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.confirmed_at is not null then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('confirmed_at', _record.confirmed_at);
        call auth.log(_log_type, false, _email, 'Email confirmation code has already been used.', _analytics);
        return auth.create_login_response();
    end if;

    _user_id = (select user_id from public.auth_users where user_id = _record.user_id);

    if _user_id is null then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id);
        call auth.log(_log_type, true, _email, format('User id %s from auth_email_confirmations record does not exists in auth_users.', _record.user_id), _analytics);
        return auth.create_login_response();
    end if;

    update public.auth_email_confirmations
    set 
        confirmed_at = _now
    where 
        user_id = _user_id and code = _code;

    select 
        u.user_id, u.email, u.expires_at, u.active_after,
        array_agg(r.name) as roles
    into _record
    from public.auth_users u 
    left join public.auth_users_roles ur using(user_id)
    join public.auth_roles r using (role_id)
    where 
        u.user_id = _user_id
    group by 
        u.user_id, u.email, u.expires_at, u.active_after;

    if _record.expires_at is not null and _record.expires_at < _now then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id, 'expires_at', _record.expires_at);
        call auth.log(_log_type, false, _email, 'User is expired in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _record.active_after is not null and _record.active_after > _now then
        _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id, 'active_after', _record.active_after);
        call auth.log(_log_type, false, _email, 'User is not active in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    -- user is good to go
    update public.auth_users
    set 
        password_attempts = 0,
        password_confirmed = true
    where 
        user_id = _user_id;

    insert into public.auth_user_logins
    (email, user_id, provider_id, analytics)
    values
    (_record.email, _user_id, 1, _analytics);

    insert into public.auth_user_providers
    (user_id, provider_id)
    values
    (_user_id, 1)
    on conflict (user_id, provider_id) do nothing;

    _analytics = coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _record.user_id, 'email', _record.email, 'roles', _record.roles);
    call auth.log(_log_type, false, _email, 'User confirmed email and logged in.', _analytics);
    return auth.create_login_response(true, _record.user_id, _record.email, _record.roles);
end;
$$;

call _.annotate('auth.confirm_email', 
    'HTTP POST', 
    'anonymous',
    'login'
);
