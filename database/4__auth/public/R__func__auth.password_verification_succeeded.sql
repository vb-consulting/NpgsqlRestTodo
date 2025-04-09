call _.drop('auth.password_verification_succeeded');

create procedure auth.password_verification_succeeded(
    _scheme text,
    _user_id text,
    _user_name text
) 
security definer
language plpgsql
as 
$$
declare
    _id bigint = _user_id::bigint;
begin
    if (select password_attempts from auth_users where user_id = _id) > 0 then
        update auth_users
        set 
            password_attempts = 0
        where 
            user_id = _id;
    end if;

    insert into auth_user_logins
    (email, user_id, provider_id)
    values
    (_user_name, _id, 1);

    insert into auth_user_providers
    (user_id, provider_id)
    values
    (_id, 1)
    on conflict (user_id, provider_id) do nothing;

    call auth.log('login', true, _user_name, 'User logged in.', jsonb_build_object('user_id', _id, 'username', _user_name));
end;
$$;
