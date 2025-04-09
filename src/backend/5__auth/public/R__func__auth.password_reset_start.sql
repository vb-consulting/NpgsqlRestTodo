call _.drop('auth.password_reset_start');

create function auth.password_reset_start(
    _code text,
    _email text,
    _token text,
    _timezone text,
    _analytics jsonb = '{}'
) 
returns text
security definer
language plpgsql
set search_path = public, pg_catalog
as 
$$
declare
    _record record;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _change_interval constant interval = auth.setting('email_reset_form_expires_in')::interval;
    _form_expires_at timestamptz;
begin 
    _analytics = _.append_ip_address(_analytics);
    select
        user_id, link_opened_at, form_expires_at
    into _record
    from public.auth_email_resets 
    where 
        code = _code and expires_at > _now
    order by expires_at desc
    limit 1;

    if _record is null then
        call auth.log('password_reset', false, _email, 'Email reset code could not be located within expiration interval.', _analytics);
        -- dont notice user that code and email is invalid, just return null and redirect to login
        return null;
    end if;

    if _record.form_expires_at is not null then
        _form_expires_at = _record.form_expires_at;
    else
        _form_expires_at = _now + _change_interval;
    end if;

    update public.auth_email_resets
    set 
        link_opened_at = _now,
        form_expires_at = _form_expires_at,
        token = _token
    where 
        user_id = _record.user_id and code = _code;

    call auth.log(
        'password_reset',
        true, 
        _email, 
        'Email reset session started.', 
        _analytics::jsonb || jsonb_build_object(
            'user_id', _record.user_id,
            'email', _email,
            'reset_code', _code,
            'token', _token,
            'form_expires_at', _form_expires_at
        )
    );

    return (_form_expires_at at time zone _timezone)::text;
end;
$$;

call _.annotate('auth.password_reset_start', 
    'HTTP POST', 
    'anonymous',
    'security_sensitive'
);
