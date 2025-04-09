call _.drop('auth.validate_password');

create function auth.validate_password(
    _email text,
    _password text,
    _repeat text,
    _analytics jsonb,
    _log_type text = 'register'
)
returns auth.register_response
security definer
language plpgsql
as
$$
declare
    _min_password_length constant int = auth.setting('min_password_length')::int;
    _required_uppercase constant int = auth.setting('required_uppercase')::int;
    _required_lowercase constant int = auth.setting('required_lowercase')::int;
    _required_number constant int = auth.setting('required_number')::int;
    _required_special constant int = auth.setting('required_special')::int;
begin 
    if _password is null or _password = '' then
        return auth.create_register_response(2, 'Password is required.');
    end if;

    if _password <> _repeat then
        return auth.create_register_response(3, 'Passwords do not match.');
    end if;

    if length(_password) < _min_password_length then
        return auth.create_register_response(4, format('Password must be at least %s characters.', _min_password_length));
    end if;

    if coalesce(_required_uppercase, 0) > 0 and (
        select count(*) from regexp_matches(_password, '[A-Z]', 'g')
    ) < _required_uppercase then
        return auth.create_register_response(5, format('Password must contain at least %s uppercase letter.', _required_uppercase));
    end if;

    if coalesce(_required_lowercase, 0) > 0 and (
        select count(*) from regexp_matches(_password, '[a-z]', 'g')
    ) < _required_lowercase then
        return auth.create_register_response(6, format('Password must contain at least %s lowercase letter.', _required_lowercase));
    end if;

    if coalesce(_required_number, 0) > 0 and (
        select count(*) from regexp_matches(_password, '[0-9]', 'g')
    ) < _required_number then
        return auth.create_register_response(7, format('Password must contain at least %s number.', _required_number));
    end if;

    if coalesce(_required_special, 0) > 0 and (
        select count(*) from regexp_matches(_password, '[^a-zA-Z0-9]', 'g')
    ) < _required_special then
        return auth.create_register_response(8, format('Password must contain at least %s special character.', _required_special));
    end if;

    -- Password is valid
    return null;
end
$$;
