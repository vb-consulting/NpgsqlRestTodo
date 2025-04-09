call _.drop('auth.password_verification_failed');

create procedure auth.password_verification_failed(
    _scheme text,
    _user_id text,
    _user_name text
) 
security definer
language plpgsql
set search_path = public, pg_catalog
as 
$$
declare
    _id bigint = _user_id::bigint;
    _attempt int;
    _now constant timestamptz = _.setting('now')::timestamptz;
    _login_max_attempts constant int = auth.setting('login_max_attempts')::int;
    _lockout_interval constant interval = auth.setting('lockout_interval')::interval;
begin
    update public.auth_users
    set password_attempts = password_attempts + 1
    where user_id = _id
    returning password_attempts into _attempt;

    if _attempt >= _login_max_attempts then
        update public.auth_users
        set active_after = _now + _lockout_interval
        where user_id = _id;

        call auth.log(
            _type => 'login', 
            _success => false, 
            _username => _user_name, 
            _message => 'User is locked out in logging attempt', 
            _analytics => jsonb_build_object(
                'user_id', _id, 
                'username', _user_name, 
                'locked_out', true, 
                'attempt', _attempt,
                'max_attempts', _login_max_attempts,
                'lockout_interval', _lockout_interval
            )
        );
    else
        call auth.log(
            _type => 'login', 
            _success => false, 
            _username => _user_name, 
            _message => 'Invalid password in logging attempt', 
            _analytics => jsonb_build_object(
                'user_id', _id, 
                'username', _user_name,
                'invalid_password', true
            )
        );
    end if;
end;
$$;
