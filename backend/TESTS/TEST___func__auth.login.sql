do
$$
declare
    _record record;
    _now timestamptz = '2020-01-01 00:00:00';
begin
    -- mute the logs for this test transaction
    call sys.set_current_setting('sys.muted', 'true');

    select * into _record from auth.login('xx', '');
    assert _record.status = 404, 'Invalid email should return 404';

    select * into _record from auth.login('notexsists@notexsists', '');
    assert _record.status = 404, 'User does not exist should return 404';

    -- mock the now setting for this test transaction
    call sys.set_current_setting('sys.now', _now::text);
    insert into auth_users (email, expires_at) values ('user@expired', _now - interval '1 day');
    select * into _record from auth.login('user@expired', '');
    assert _record.status = 404, 'User expired should return 404';

    insert into auth_users (email, active_after) values ('user@inactive', _now + interval '1 day');
    select * into _record from auth.login('user@inactive', '');
    assert _record.status = 404, 'User inactive should return 404';
    -- reset the now setting
    call sys.set_current_setting('sys.now', null);

    insert into auth_users (email, confirmed) values ('user@unconfirmed', false);
    select * into _record from auth.login('user@unconfirmed', '');
    assert _record.status = 404, 'User unconfirmed should return 404';

    insert into auth_users (email, password_hash, confirmed) values ('user@nopassword', null, true);
    select * into _record from auth.login('user@nopassword', '');
    assert _record.status = 404, 'User without password should return 404';

    insert into auth_users (email, password_hash, confirmed) values ('user@badpassword', crypt('password', gen_salt('bf')), true);
    select * into _record from auth.login('user@badpassword', 'badpassword');
    assert _record.status = 404, 'Invalid password should return 404';

    perform auth.login('user@badpassword', 'badpassword'); --attempt 2
    perform auth.login('user@badpassword', 'badpassword'); --attempt 3
    perform auth.login('user@badpassword', 'badpassword'); --attempt 4
    select * into _record from auth.login('user@badpassword', 'badpassword'); --attempt 5

    assert _record.status = 404, 'User locked out should return 404';

    insert into auth_users (email, password_hash, confirmed) values ('user@goodpassword', crypt('password', gen_salt('bf')), true);
    select * into _record from auth.login('user@goodpassword', 'password');
    assert _record.status = 404, 'Valid password but without any roles should return 404';

    insert into auth_users_roles (user_id, role_id) 
    values (
        (select user_id from auth_users where email = 'user@goodpassword'), 
        (select role_id from auth_roles where name = 'user')
    );
    select * into _record from auth.login('user@goodpassword', 'password');
    assert _record.status = 200, 'Valid password should return 200';

    -- All tests passed
    raise notice 'All auth login tests passed successfully!';

    ROLLBACK;
end;
$$;

-- reset user_id sequence
select setval('auth_users_user_id_seq', coalesce((select max(user_id) from auth_users) + 1, 1), false);
