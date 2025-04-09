call sys.drop('auth.password_reset');

create function auth.password_reset(
    _code text,
    _token text,
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
    _record record;
    _now constant timestamptz = sys.setting('now')::timestamptz;
    _validate_response auth.register_response;
    _log_type constant text = 'password_reset';
begin 
    _analytics_data = sys.add_jsonb_key(_analytics_data, 'ip', _ip_address);

    _validate_response = auth.validate_password(_email, _password, _repeat, _analytics_data, _log_type);
    if _validate_response.code is not null then
        return _validate_response;
    end if;

    select
        user_id, form_expires_at, token, email
    into _record
    from auth_email_resets 
    where 
        code = _code
    order by expires_at desc
    limit 1;

    if  (_record is null) or 
        (_record.token <> _token) or 
        (_record.form_expires_at is null) or
        (_record.email <> _email)
    then
        call auth.log(
            _log_type, false,_email, 
            'Password reset is invalid: ' || array_to_string(array[ 
                case when _record is null then format('code %s could not be found', _code) else null end, 
                case when _record.token <> _token then 'Invalid token ' || _token else null end,
                case when _record.form_expires_at is null then 'form expiration is null' || _token else null end,
                case when _record.email <> _email is null then format('email from record %s doesn0t match email from inoput %s', _record.email, _emai) else null end
            ], ', '), 
            _analytics_data
        );
        return (100, 'Password reset is invalid.')::auth.register_response;

    end if;

    if _record.form_expires_at < _now then
        return auth.create_register_response(
            101, 'Password reset request is expired.', _email, _analytics_data, _log_type
        );
    end if;

    update auth_users
    set 
        password_hash = sys.hash_to_array(_password),
        analytics_data = _analytics_data,
        providers = case 
            when providers is null then array['password']
            when not 'password' = any(providers) then array_append(providers, 'password')
            else providers
        end
    where 
        user_id = _record.user_id;

    return auth.create_register_response(0, 'Success.', _email, _analytics_data, _log_type);
end;
$$;

call sys.annotate('auth.password_reset', 
    'HTTP POST', 
    'Anonymous'
);
