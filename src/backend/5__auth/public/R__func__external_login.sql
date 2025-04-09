call _.drop('auth.external_login');

create function auth.external_login(
    _provider text,
    _email text,
    _name text,
    _provider_data json,
    _analytics_data json
)
returns auth.login_response
security definer
language plpgsql
set search_path = public, pg_catalog
as
$$
declare
    _provider_id int;
    _user_id bigint;
    _expires_at timestamptz = null;
    _active_after timestamptz = null;
    _roles text[] = null;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _default_roles constant text[] = auth.setting('default_roles')::text[];
    _log_type constant text = 'external_login';
    _analytics jsonb = coalesce(_analytics_data::jsonb, '{}'::jsonb) || jsonb_build_object(
        'external_provider', _provider,
        'external_name', _name,
        'email', _email
    );
begin
    _provider_id = (select provider_id from public.auth_providers where name = lower(_provider));
    if _provider_id is null then
        call auth.log(_log_type, false, _email, 
            format('External login provider %s not found in registered providers: %s', _provider, (select array_agg(name) from auth_providers)), 
            _analytics
        );
        return auth.create_login_response();
    end if;

    select 
        u.user_id, u.expires_at, u.active_after, array_agg(r.name) as roles
    into 
        _user_id, _expires_at, _active_after, _roles
    from public.auth_users u
    left join public.auth_users_roles ur using(user_id)
    join public.auth_roles r using (role_id)
    where u.email = _email
    group by u.user_id, u.expires_at, u.active_after;

    if _user_id is null then
        insert into public.auth_users (email) values (_email)
        on conflict (email) do update set email = EXCLUDED.email
        returning user_id into _user_id;
    end if;

    if _roles is null then
            insert into public.auth_users_roles
            (user_id, role_id)
            select
                _user_id,
                r.role_id
            from public.auth_roles r
            where r.name = any(_default_roles)
            on conflict (user_id, role_id) do nothing;

            _roles = (
                select array_agg(r.name) 
                from public.auth_users_roles ur 
                join public.auth_roles r using(role_id) 
                where ur.user_id = _user_id
            );
    end if;

    if _expires_at is not null and _expires_at < _now then
        _analytics = _analytics || jsonb_build_object('expires_at', _expires_at);
        call auth.log(_log_type, false, _email, 'User is expired in logging attempt.', _analytics);
        return auth.create_login_response();
    end if;

    if _active_after is not null and _active_after > _now then
        _analytics = _analytics || jsonb_build_object('active_after', _active_after);
        call auth.log(_log_type, false, _email, 'User is not active in logging attempt', _analytics);
        return auth.create_login_response();
    end if;

    insert into public.auth_user_logins
    (email, user_id, provider_id, provider_data, analytics)
    values
    (_email, _user_id, _provider_id, _provider_data::jsonb, _analytics);

    insert into public.auth_user_providers
    (user_id, provider_id)
    values
    (_user_id, _provider_id)
    on conflict (user_id, provider_id) do nothing;

    call auth.log(_log_type, true, _email, 'External login.', _analytics);
    return auth.create_login_response(true, _user_id, _email, _roles);
end
$$;
