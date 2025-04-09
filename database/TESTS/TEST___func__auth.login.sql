do
$$
declare
    _record record;
    _now timestamptz = '2020-01-01 00:00:00';
    _user_id bigint;
    _scheme text = auth.setting('default_scheme');
begin
    -- mute the logs for this test transaction
    call _.set_current_setting('_.muted', 'true');

    select * into _record from auth.login('xx', '');
    assert _record.status = 404, 'Invalid email should return 404';

    select * into _record from auth.login('notexsists@notexsists', '');
    assert _record.status = 404, 'User does not exist should return 404';

    -- mock the now setting for this test transaction
    call _.set_current_setting('_.now', _now::text);
    insert into auth_users (email, expires_at) values ('user@expired', _now - interval '1 day');
    select * into _record from auth.login('user@expired', '');
    assert _record.status = 404, 'User expired should return 404';

    insert into auth_users (email, active_after) values ('user@inactive', _now + interval '1 day');
    select * into _record from auth.login('user@inactive', '');
    assert _record.status = 404, 'User inactive should return 404';
    -- reset the now setting
    call _.set_current_setting('_.now', null);

    insert into auth_users (email, password_confirmed) values ('user@unconfirmed', false);
    select * into _record from auth.login('user@unconfirmed', '');
    assert _record.status = 404, 'User unconfirmed should return 404';

    insert into auth_users (email, password_hash, password_confirmed) values ('user@nopassword', null, true);
    select * into _record from auth.login('user@nopassword', '');
    assert _record.status = 404, 'User without password should return 404';

    insert into auth_users (email, password_hash, password_confirmed) 
    values ('user@badpassword', 'badhash', true) 
    returning user_id into _user_id;

    select * into _record from auth.login('user@badpassword', 'badpassword');
    call auth.password_verification_failed(_scheme, _user_id::text, 'user@badpassword');
    assert _record.status = 404, 'Invalid password should return 404';

    perform auth.login('user@badpassword', 'badpassword'); --attempt 2
    call auth.password_verification_failed(_scheme, _user_id::text, 'user@badpassword');

    perform auth.login('user@badpassword', 'badpassword'); --attempt 3
    call auth.password_verification_failed(_scheme, _user_id::text, 'user@badpassword');

    perform auth.login('user@badpassword', 'badpassword'); --attempt 4
    call auth.password_verification_failed(_scheme, _user_id::text, 'user@badpassword');

    select * into _record from auth.login('user@badpassword', 'badpassword'); --attempt 5
    call auth.password_verification_failed(_scheme, _user_id::text, 'user@badpassword');

    assert _record.status = 404, 'User locked out should return 404';

    insert into auth_users (email, password_hash, password_confirmed) 
    values ('user@goodpassword', 'goodhash', true)
    returning user_id into _user_id;

    select * into _record from auth.login('user@goodpassword', 'password');
    call auth.password_verification_succeeded(_scheme, _user_id::text, 'user@goodpassword');
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
