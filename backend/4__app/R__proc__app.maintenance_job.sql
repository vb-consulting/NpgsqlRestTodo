call sys.drop('app.maintenance_job');

create procedure app.maintenance_job()
language plpgsql
security definer
as 
$$
declare
    _ts timestamptz = now();
    _next_day timestamptz = date_trunc('day', _ts) + interval '1 day';
    _next_month timestamptz = date_trunc('month', _ts) + interval '1 month';
    _rec record;
    _msg text = '';
begin
    call sys.create_range_partition(_name => 'logs.app_log', _timestamp => _ts, _monthly => true);
    call sys.create_range_partition(_name => 'logs.app_log', _timestamp => _next_month, _monthly => true);

    call sys.create_range_partition(_name => 'logs.auth_log', _timestamp => _ts, _monthly => true);
    call sys.create_range_partition(_name => 'logs.auth_log', _timestamp => _next_month, _monthly => true);

    call sys.create_range_partition(_name => 'auth_email_confirmations', _timestamp => _ts, _monthly => false);
    call sys.create_range_partition(_name => 'auth_email_confirmations', _timestamp => _next_day, _monthly => false);

    for _rec in (
        select p.partition 
        from sys.get_partition_range('auth_email_confirmations') p
        where p.partition_to < _ts - interval '1 month'
    ) loop
        _msg = _msg || format(
            'ALTER TABLE auth_email_confirmations DETACH PARTITION %1$s CONCURRENTLY;\nDROP TABLE %1$s;\n', 
            _rec.partition
        );
    end loop;

    for _rec in (
        select p.partition 
        from sys.get_partition_range('logs.app_log') p
        where p.partition_to < _ts - interval '6 months'
    ) loop
        _msg = _msg || format(
            'ALTER TABLE logs.app_log DETACH PARTITION %1$s CONCURRENTLY;\nDROP TABLE %1$s;\n', 
            _rec.partition
        );
    end loop;

    for _rec in (
        select p.partition 
        from sys.get_partition_range('logs.auth_log') p
        where p.partition_to < _ts - interval '6 months'
    ) loop
        _msg = _msg || format(
            'ALTER TABLE logs.auth_log DETACH PARTITION %1$s CONCURRENTLY;\nDROP TABLE %1$s;\n', 
            _rec.partition
        );
    end loop;

    if _msg <> '' then
        _msg = 'Staled partitions detected! Recommended action:\n' || _msg;
        raise warning '%', _msg;
        call app.log('W', _msg, _ts, null, 'app.maintenance_job');
    end if;
end;
$$;

