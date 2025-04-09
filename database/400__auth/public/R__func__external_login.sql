call sys.drop('auth.external_login');

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
as
$$
declare
    _provider_id int;
    _user_id bigint;
    _expires_at timestamptz = null;
    _active_after timestamptz = null;
    _roles text[] = null;
    _now constant timestamptz = sys.setting('now')::timestamptz;
    _default_roles constant text[] = auth.setting('default_roles')::text[];
begin
    _analytics_data = _analytics_data::jsonb || jsonb_build_object(
        'external_provider', _provider,
        'external_name', _name,
        'email', _email
    );

    _provider_id = (select provider_id from auth_providers where name = lower(_provider));
    if _provider_id is null then
        return auth.create_login_response(
            'external_login',
            format('External login provider %s not found in registered providers: %s', 
                _provider, 
                (select array_agg(name) from auth_providers)
            ),
            _email, 
            _analytics_data::jsonb
        );
    end if;

    select 
        u.user_id, u.expires_at, u.active_after, array_agg(r.name) as roles
    into 
        _user_id, _expires_at, _active_after, _roles
    from auth_users u
    left join auth_users_roles ur using(user_id)
    join auth_roles r using (role_id)
    where u.email = _email
    group by u.user_id, u.expires_at, u.active_after;

    if _user_id is null then
        insert into auth_users (email) values (_email)
        on conflict (email) do update set email = EXCLUDED.email
        returning user_id into _user_id;
    end if;

    if _roles is null then
        insert into auth_users_roles
        (user_id, role_id)
        select
            _user_id,
            r.role_id
        from auth_roles r
        where r.name = any(_default_roles)
        on conflict (user_id, role_id) do nothing;
    end if;

    if _expires_at is not null and _expires_at < _now then
        return auth.create_login_response('external_login', 'User is expired in logging attempt. %s', _email, _analytics_data::jsonb);
    end if;

    if _active_after is not null and _active_after > _now then
        return auth.create_login_response('external_login', 'User is not active in logging attempt. %s', _email, _analytics_data::jsonb);
    end if;

    insert into auth_user_logins
    (email, user_id, provider_id, provider_data, analytics_data)
    values
    (_email, _user_id, _provider_id, _provider_data::jsonb, _analytics_data::jsonb);

    return auth.create_login_response(
        _type => 'external_login',
        _log_message => 'User %s logged in.',
        _analytics_data => _analytics_data::jsonb,
        _success => true,
        _name_identifier => _user_id::text,
        _name => _email,
        _role => _roles,
        _message => json_build_object(
            'id', _user_id::text, 
            'name', _email, 
            'roles', _roles
        )
    );
end
$$;
