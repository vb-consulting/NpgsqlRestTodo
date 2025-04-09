do
$$
begin
    -- mute the logs for this test transaction
    call _.set_current_setting('_.muted', 'true');
    call _.set_current_setting('auth.require_email_confirmation', 'false');

    insert into auth_users (email) values ('test@test.com');

    assert auth.register('', '', '') = (1, 'Invalid email.')::auth.register_response, '1. Invalid email assert failed.';
    assert auth.register('xxx', '', '') = (1, 'Invalid email.')::auth.register_response, '2. Invalid email assert failed.';

    assert auth.register('test2@test2.com', '', '') = (2, 'Password is required.')::auth.register_response, '4. Password is required assert failed.';
    assert auth.register('test2@test2.com', '123456', '654321') = (3, 'Passwords do not match.')::auth.register_response, '5. Passwords do not match assert failed.';
    assert auth.register('test2@test2.com', '12345', '12345') = (4, 'Password must be at least 6 characters.')::auth.register_response, '6. Password must be at least 6 characters assert failed.';

    assert auth.register('test2@test2.com', 'abcxyz', 'abcxyz') = (5, 'Password must contain at least 1 uppercase letter.')::auth.register_response, '8. Password must contain at least 1 uppercase letter assert failed.';
    assert auth.register('test2@test2.com', 'ABCXYZ', 'ABCXYZ') = (6, 'Password must contain at least 1 lowercase letter.')::auth.register_response, '9. Password must contain at least 1 lowercase letter assert failed.';
    assert auth.register('test2@test2.com', 'Abcxyz', 'Abcxyz') = (7, 'Password must contain at least 1 number.')::auth.register_response, '10. Password must contain at least 1 number assert failed.';
    assert auth.register('test2@test2.com', 'Abcxyz1', 'Abcxyz1') = (8, 'Password must contain at least 1 special character.')::auth.register_response, '11. Password must contain at least 1 special character assert failed.';
    
    assert auth.register('test@test.com', 'Abcxyz1*', 'Abcxyz1*') = (10, null)::auth.register_response, '12. User already exists.';
    assert auth.register('test2@test2.com', 'Abcxyz1*', 'Abcxyz1*', _hash => 'some hash') = (0, null)::auth.register_response, '13. Success assert failed.';

    assert (
        select count(*) 
        from auth_users 
        where 
            email = 'test2@test2.com' 
            and password_hash = 'some hash'
            and password_confirmed = true
    ) = 1,
    '14. Created user exists assert failed.';

    assert (
        select array_agg(r.name)
        from auth_users u 
            left join auth_users_roles ur using(user_id)
            join auth_roles r using (role_id)
        where email = 'test2@test2.com'
    ) @> auth.setting('default_roles')::text[],
    '15. Default roles for user assert failed.';

    -- All tests passed
    raise notice 'All auth register tests passed successfully!';

    ROLLBACK;
end
$$;

-- reset user_id sequence
-- select setval('auth_users_user_id_seq', coalesce((select max(user_id) from auth_users) + 1, 1), false);
