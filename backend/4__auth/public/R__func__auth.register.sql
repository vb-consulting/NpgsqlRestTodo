call sys.drop('auth.create_register_response');
call sys.drop('auth.register');
drop type if exists auth.register_response;

create type auth.register_response as (
    code int,
    message text
);

-- Create a factory function to create the register response type.
create function auth.create_register_response(
    _code int,
    _message text,
    _email text
)
returns auth.register_response
language plpgsql
as
$$
begin
    call auth.log(_type => 'R', _success => _code = 0, _username => _email, _message => _message, _data => '{}');
    return (_code, _message)::auth.register_response;
end
$$;

create or replace function auth.register(
    _email text,
    _password text,
    _repeat text
)
returns auth.register_response
security definer
language plpgsql
as
$$
declare
    _existing record;
    _algorithm constant text = auth.setting('algorithm');
    _max_password_length constant int = auth.setting('max_password_length')::int;
    _min_password_length constant int = auth.setting('min_password_length')::int;
    _required_uppercase constant int = auth.setting('required_uppercase')::int;
    _required_lowercase constant int = auth.setting('required_lowercase')::int;
    _required_number constant int = auth.setting('required_number')::int;
    _required_special constant int = auth.setting('required_special')::int;
    _default_roles constant text[] = auth.setting('default_roles')::text[];

    _require_email_confirmation constant boolean = auth.setting('require_email_confirmation')::boolean;
    _email_confirmation_code_len constant int = auth.setting('email_confirmation_code_len')::int;
    _email_confirmation_expires_in constant interval = auth.setting('email_confirmation_expires_in')::interval;

    _created_user_id bigint;
begin 
    if sys.validate_email(_email) is false then
        return auth.create_register_response(1, 'Invalid email.', _email);
    end if;

    if _password is null or _password = '' then
        return auth.create_register_response(2, 'Password is required.', _email);
    end if;

    if _password <> _repeat then
        return auth.create_register_response(3, 'Passwords do not match.', _email);
    end if;

    if length(_password) < _min_password_length then
        return auth.create_register_response(4, format('Password must be at least %s characters.', _min_password_length), _email);
    end if;

    if length(_password) > _max_password_length then
        return auth.create_register_response(5, format('Password must be less than %s characters.', _max_password_length), _email);
    end if;

    if coalesce(_required_uppercase, 0) > 0 and (select count(*) from regexp_matches(_password, '[A-Z]', 'g')) < _required_uppercase then
        return auth.create_register_response(6, format('Password must contain at least %s uppercase letter.', _required_uppercase), _email);
    end if;

    if coalesce(_required_lowercase, 0) > 0 and (select count(*) from regexp_matches(_password, '[a-z]', 'g')) < _required_lowercase then
        return auth.create_register_response(7, format('Password must contain at least %s lowercase letter.', _required_lowercase), _email);
    end if;

    if coalesce(_required_number, 0) > 0 and (select count(*) from regexp_matches(_password, '[0-9]', 'g')) < _required_number then
        return auth.create_register_response(8, format('Password must contain at least %s number.', _required_number), _email);
    end if;

    if coalesce(_required_special, 0) > 0 and (select count(*) from regexp_matches(_password, '[^a-zA-Z0-9]', 'g')) < _required_special then
        return auth.create_register_response(9, format('Password must contain at least %s special character.', _required_special), _email);
    end if;

    select user_id, email, providers, confirmed 
    into _existing 
    from auth_users 
    where email = _email;

    if _existing is not null then
        return auth.create_register_response(10, 'Success.', _email);
    end if;

    insert into auth_users (
        email, 
        password_hash, 
        providers, 
        confirmed
    ) 
    values (
        _email, 
        crypt(_password, gen_salt(_algorithm)),
        array['password'],
        case when _require_email_confirmation is true then false else true end
    )
    on conflict (email) do nothing
    returning user_id into _created_user_id;

    if _created_user_id is null then
        return auth.create_register_response(10, 'Success.', _email);
    end if;

    insert into auth_users_roles
        (user_id, role_id)
    select
        _created_user_id,
        r.role_id
    from auth_roles r
    where r.name = any(_default_roles);

    if _require_email_confirmation is true then
        --call auth.send_email_confirmation(_email);
    end if;

    return auth.create_register_response(0, 'Success.', _email);
end
$$;

call sys.annotate('auth.register', 
    'HTTP POST', 
    'Anonymous'
);
