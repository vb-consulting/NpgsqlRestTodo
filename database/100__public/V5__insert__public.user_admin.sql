do
$$
declare
    _admin_user_id bigint;
begin

    insert into auth_users (
        email, 
        password_hash, 
        password_confirmed
    )
    values (
        'admin@todo',
        decode('246172676f6e32696424763d3139246d3d3236323134342c743d332c703d31246864652b4e686b6c6c7a3461344c454e3731796e7867245a676d653430676966432b4f4876345338334e685259516e33464e33624f77766b576b46726a5659347167000000000000000000000000000000000000000000000000000000000000', 'hex'),
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
