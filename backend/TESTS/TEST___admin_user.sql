do
$$
declare
    _record record;
    _admin text = 'admin@todo';
begin
    select * into _record from auth_users where email = _admin;

    assert _record.user_id = 1, 'Admin user not found';
    assert _record.email = _admin, 'Admin user not found';
    assert _record.confirmed = true, 'Admin user should be confirmed';
    assert _record.active_after is null, 'Admin user active_after not null';
    assert _record.expires_at is null, 'Admin user expires_at not null';
    assert _record.password_hash is not null, 'Admin user password_hash is null';
    assert (
        select array_agg(r.name)
        from auth_users u 
            left join auth_users_roles ur using(user_id)
            join auth_roles r using (role_id)
        where email = _admin
    )::text[] = array['system']::text[],
    'Admin should have system role.';

    -- All tests passed
    raise notice 'All admin user tests passed successfully!';
end;
$$;
