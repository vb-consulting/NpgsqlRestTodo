call _.drop('auth.password_reset');

create function auth.password_reset(
    _code text,
    _token text,
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
    _record record;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _validate_response auth.register_response;
    _log_type constant text = 'password_reset';
begin 
    _analytics = _.append_ip_address(_analytics);

    _validate_response = auth.validate_password(_email, _password, _repeat, _analytics, _log_type);
    if _validate_response.code is not null then
        return _validate_response;
    end if;

    select
        user_id, form_expires_at, token, email
    into _record
    from public.auth_email_resets 
    where 
        code = _code
    order by expires_at desc
    limit 1;

    if  (_record is null) or 
        (_record.token <> _token) or 
        (_record.form_expires_at is null) or
        (_record.email <> _email)
    then
        call auth.log(_log_type, false, _email, 
            'Password reset is invalid: ' || array_to_string(array[ 
                case when _record is null then format('code %s could not be found', _code) else null end, 
                case when _record.token <> _token then 'Invalid token ' || _token else null end,
                case when _record.form_expires_at is null then 'form expiration is null' || _token else null end,
                case when _record.email <> _email is null then format('email from record %s doesn0t match email from inoput %s', _record.email, _emai) else null end
            ], ', '), 
            _analytics
        );
        return auth.create_register_response(100, 'Password reset is invalid.');

    end if;

    if _record.form_expires_at < _now then
        call auth.log(_log_type, false, _email, 'Password reset request is expired while attemtping to call auth.password_reset', _analytics);
        return auth.create_register_response(101, 'Password reset request is expired.');
    end if;

    update public.auth_users
    set 
        password_hash = _hash,
        password_attempts = 0
    where 
        user_id = _record.user_id;

    call auth.log(_log_type, true, _email, 'Password reset success', _analytics);
    return auth.create_register_response(0, null);
end;
$$;

call _.annotate('auth.password_reset', 
    'HTTP POST', 
    'anonymous',
    'security_sensitive',
    'parameter _hash is hash of _password'
);
