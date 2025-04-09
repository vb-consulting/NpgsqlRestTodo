call _.drop('auth.password_reset_code');

create function auth.password_reset_code(
    _email text,
    _analytics jsonb
) 
returns text
security definer
language plpgsql
set search_path = public, pg_catalog
as 
$$
declare 
    _code_len constant int = auth.setting('email_reset_code_len')::int;
    _link_expires_in constant interval = auth.setting('email_reset_link_expires_in')::interval;
    _max_attempts constant int = auth.setting('email_reset_max_attempts')::int;
    _retry_interval constant interval = auth.setting('email_reset_retry_interval')::interval;
    _reset_code text;
    _enqueue_job_id bigint;
    _expires_at timestamptz;
    _user_id bigint;
begin
    _analytics = _.append_ip_address(_analytics);
    if _.validate_email(_email) is false then
        call auth.log('password_reset_code', false, _email, format('Invalid email %s in reset attempt.', _email), _analytics);
        -- notice user that email is invalid
        return null;
    end if;

    _user_id = (
        select user_id
        from public.auth_users
        where email = _email
        limit 1
    );

    if _user_id is null then
        call auth.log('password_reset_code', false, _email, format('User with email %s not found in reset attempt.', _email), _analytics);
        -- return success, we don't want to leak if the email exists
        return _.generate_rnd_code(6);
    end if;

    _reset_code = (
        select _.generate_rnd_code(_code_len)
    );
    
    _expires_at = now() + _link_expires_in;

    insert into public.auth_email_resets (
        expires_at,
        email, 
        code, 
        user_id, 
        link_opened_at,
        form_expires_at,
        token
    )
    values (
        _expires_at,
        _email, 
        _reset_code, 
        _user_id, 
        null,
        null,
        null
    );

    _enqueue_job_id = (
        select app.enqueue_job(
            _payload => jsonb_build_object(
                'module', 'EmailReset.js',
                'params', array[_email, _reset_code, _user_id]::text[]
            ),
            _priority => 0,
            _scheduled_for => now(),
            _max_attempts => _max_attempts,
            _delay_retry => _retry_interval
        )
    );

    call auth.log(
        'password_reset_code',
        true, 
        _email, 
        'Reset email enqueued.', 
        _analytics::jsonb || jsonb_build_object(
            'user_id', _user_id,
            'email', _email,
            'reset_code', _reset_code,
            'enqueue_job_id', _enqueue_job_id,
            'expires_at', _expires_at
        )
    );

    return _.generate_rnd_code(6);
end;
$$;

call _.annotate('auth.password_reset_code', 
    'HTTP POST', 
    'anonymous',
    'security_sensitive'
);