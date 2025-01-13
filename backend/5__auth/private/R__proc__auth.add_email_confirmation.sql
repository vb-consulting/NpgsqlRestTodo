call sys.drop('auth.add_email_confirmation');

create procedure auth.add_email_confirmation(
    _email text,
    _user_id bigint,
    _analytics_data jsonb
) 
language plpgsql
as 
$$
declare 
    _email_confirmation_code_len constant int = auth.setting('email_confirmation_code_len')::int;
    _email_confirmation_expires_in constant interval = auth.setting('email_confirmation_expires_in')::interval;
    _confirmation_code text;
    _enqueue_job_id bigint;
    _expires_at timestamptz;
begin
    call sys.create_range_partition(_name => 'auth_email_confirmations', _timestamp => now(), _monthly => false);

    _confirmation_code = (
        select sys.generate_rnd_code(_email_confirmation_code_len)
    );
    
    _expires_at = now() + _email_confirmation_expires_in;

    insert into auth_email_confirmations (
        email, 
        code, 
        user_id, 
        expires_at
    )
    values (
        _email, 
        _confirmation_code, 
        _user_id, 
        _expires_at
    );

    _enqueue_job_id = (
        select app.enqueue_job(
            _payload => jsonb_build_object(
                'module', 'EmailConfirmation.js',
                'params', array[_email, _confirmation_code, _user_id]::text[]
            ),
            _priority => 0,
            _scheduled_for => now(),
            _max_attempts => 5,
            _delay_retry => '2 minutes'
        )
    );

    call auth.log_code(
        true, 
        _email, 
        'Confirmation email enqueued.', 
        _analytics_data::jsonb || jsonb_build_object(
            'user_id', _user_id,
            'email', _email,
            'confirmation_code', _confirmation_code,
            'enqueue_job_id', _enqueue_job_id,
            'expires_at', _expires_at
        )
    );
end;
$$;
