call _.drop('auth.add_email_confirmation');

create procedure auth.add_email_confirmation(
    _email text,
    _user_id bigint,
    _analytics jsonb
) 
language plpgsql
set search_path = public, pg_catalog
as 
$$
declare 
    _code_len constant int = auth.setting('email_confirmation_code_len')::int;
    _link_expires_in constant interval = auth.setting('email_confirmation_link_expires_in')::interval;
    _max_attempts constant int = auth.setting('email_confirmation_max_attempts')::int;
    _retry_interval constant interval = auth.setting('email_confirmation_retry_interval')::interval;
    _confirmation_code text;
    _enqueue_job_id bigint;
    _expires_at timestamptz;
begin
    _confirmation_code = (
        select _.generate_rnd_code(_code_len)
    );
    
    _expires_at = now() + _link_expires_in;

    insert into public.auth_email_confirmations (
        expires_at,
        email, 
        code, 
        user_id
    )
    values (
        _expires_at,
        _email, 
        _confirmation_code, 
        _user_id
    );

    _enqueue_job_id = (
        select app.enqueue_job(
            _payload => jsonb_build_object(
                'module', 'EmailConfirmation.js',
                'params', array[_email, _confirmation_code, _user_id]::text[]
            ),
            _priority => 0,
            _scheduled_for => now(),
            _max_attempts => _max_attempts,
            _delay_retry => _retry_interval
        )
    );

    call auth.log(
        'confirm_email_code',
        true, 
        _email, 
        'Confirmation email enqueued.', 
        _analytics::jsonb || jsonb_build_object(
            'user_id', _user_id,
            'email', _email,
            'confirmation_code', _confirmation_code,
            'enqueue_job_id', _enqueue_job_id,
            'expires_at', _expires_at
        )
    );
end;
$$;
