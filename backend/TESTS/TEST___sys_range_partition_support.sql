do
$$
declare
    _result record;
begin
    -- Create a test table with range partitioning
    create table monthly_partition_test_table (
        id serial,
        created_at timestamptz not null
    ) partition by range (created_at);

    -- Test 1: Create monthly partition
    call sys.create_range_partition('monthly_partition_test_table', '2025-03-01'::timestamptz, true);

    -- Verify monthly partition
    select * into _result 
    from sys.get_partition_range('monthly_partition_test_table')
    where partition = 'monthly_partition_test_table_202503';
    
    assert _result is not null, 'Monthly partition was not created';
    assert _result.partition_from = '2025-03-01 00:00:00+00', 'Monthly partition start date is incorrect';
    assert _result.partition_to = '2025-04-01 00:00:00+00', 'Monthly partition end date is incorrect';

    create table daily_partition_test_table (
        id serial,
        created_at timestamptz not null
    ) partition by range (created_at);

    -- Test 2: Create daily partition
    call sys.create_range_partition('daily_partition_test_table', '2025-03-15 14:30:00'::timestamptz, false);
    
    -- Verify daily partition
    select * into _result 
    from sys.get_partition_range('daily_partition_test_table')
    where partition = 'daily_partition_test_table_20250315';
    
    assert _result is not null, 'Daily partition was not created';
    assert _result.partition_from = '2025-03-15 00:00:00+00', 'Daily partition start date is incorrect';
    assert _result.partition_to = '2025-03-16 00:00:00+00', 'Daily partition end date is incorrect';

    -- Test 3: Attempt to create duplicate partition (should not raise error)
    call sys.create_range_partition('monthly_partition_test_table', '2025-03-01'::timestamptz, true);
    
    -- Verify only one partition exists for March
    assert (
        select count(*) 
        from sys.get_partition_range('monthly_partition_test_table')
        where partition like 'monthly_partition_test_table_202503%'
    ) = 1, 'Duplicate monthly partition was created';

    -- Test 4: Test with schema-qualified name
    create schema partition_test_schema;
    create table partition_test_schema.test_table (
        id serial,
        created_at timestamptz not null
    ) partition by range (created_at);
    
    call sys.create_range_partition('partition_test_schema.test_table', '2025-04-01'::timestamptz, true);


    select * into _result 
    from sys.get_partition_range('partition_test_schema.test_table')
    where partition = 'partition_test_schema.test_table_202504';
    
    assert _result is not null, 'Schema-qualified monthly partition was not created';
    assert _result.partition_from = '2025-04-01 00:00:00+00', 'Schema-qualified partition start date is incorrect';
    assert _result.partition_to = '2025-05-01 00:00:00+00', 'Schema-qualified partition end date is incorrect';

    -- Test 5: Test default timestamp (now())
    call sys.create_range_partition('monthly_partition_test_table'); -- Using default now()
    
    select * into _result 
    from sys.get_partition_range('monthly_partition_test_table')
    where partition = 'monthly_partition_test_table_' || to_char(now(), 'YYYYMM');
    
    assert _result is not null, 'Partition with default timestamp was not created';
    assert date_trunc('month', _result.partition_from) = date_trunc('month', now()),
        'Default timestamp partition start date is incorrect';

    -- Cleanup
    drop table monthly_partition_test_table cascade;
    drop table daily_partition_test_table cascade;
    drop schema partition_test_schema cascade;

    raise notice 'All partition tests passed successfully!';
    
    ROLLBACK;
end;
$$;