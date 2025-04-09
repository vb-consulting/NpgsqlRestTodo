do
$$
declare
    _admin_user_id bigint;
begin

    insert into auth_users (
        email, 
        password_hash, 
        providers,
        confirmed
    )
    values (
        'admin@todo',
        array['$2a$06$xMoqqNM2CUs49SJUn9Yz2uBhcVoIbwKOuvuVllxhIzzqMecLBZarW']::text[],
        array['password']::text[],
        true
    )
    on conflict (email) do nothing
    returning user_id into _admin_user_id;

    if _admin_user_id is null then
        raise warning 'Can not create admin user, user with same email name already exists!';
        return;
    end if;

    insert into auth_users_roles 
        (user_id, role_id)
    select
        _admin_user_id,
        (select role_id from auth_roles where name = 'system');

    raise info 'Admin user created with id = %', _admin_user_id;
end;
$$;
