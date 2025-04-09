do
$$
declare
    _record record;
begin
    -- mute the logs for this test transaction
    call _.set_current_setting('_.muted', 'true');

    create table temporal_test (
        id int primary key,
        name text not null
    );

    assert _.table_exists('public', 'temporal_test') is true;

    call temporal.init('temporal_test');

    assert _.schema_exists('public_history') is true;
    assert _.table_exists('public_history', 'temporal_test') is true;
    assert _.table_exists('public_history', 'temporal_test_schema_history') is true;

    assert (select count(*) from public_history.temporal_test) = 0;
    assert (select count(*) from public_history.temporal_test_schema_history) = 1;

    select * into _record from public_history.temporal_test_schema_history;
    assert _record.schema_id = 1;
    assert _record.data = array['id integer NOT NULL', 'name text NOT NULL'];

    insert into temporal_test (id, name) values (1, 'Test 1');
    assert (select count(*) from public_history.temporal_test) = 0;

    update temporal_test set name = 'Update 1' where id = 1;

    select * into _record from public_history.temporal_test;
    assert _record.schema_id = 1;
    assert _record.data = '{"id": 1, "name": "Test 1"}';

    delete from temporal_test;
    assert (select count(*) from public_history.temporal_test) = 2;
    select * into _record from public_history.temporal_test where id = 2;
    assert _record.schema_id = 1;
    assert _record.data = '{"id": 1, "name": "Update 1"}';

    alter table temporal_test add column description text;
    assert (select count(*) from public_history.temporal_test_schema_history) = 2;
    select * into _record from public_history.temporal_test_schema_history where schema_id = 2;
    assert _record.schema_id = 2;
    assert _record.data = array['id integer NOT NULL', 'name text NOT NULL', 'description text'];

    insert into temporal_test (id, name) values (3, 'New 1');
    update temporal_test set name = 'Update New 1' where id = 3;
    
    assert (select count(*) from public_history.temporal_test) = 3;
    select * into _record from public_history.temporal_test where id = 3;
    assert _record.schema_id = 2;
    assert _record.data = '{"id": 3, "name": "New 1", "description": null}';

    raise notice 'All temporal tests passed successfully!';

    ROLLBACK;
end;
$$;
