call sys.drop('app.maintenance_job');

create procedure app.maintenance_job() 
language plpgsql
security definer
as 
$$
declare
    _ts timestamptz = now();
    _next_month timestamptz = date_trunc('month', _ts) + interval '1 month';
begin
    call sys.ensure_monthly_partition('logs', 'app_log', _ts);
    call sys.ensure_monthly_partition('logs', 'auth_log', _ts);
    call sys.ensure_monthly_partition('logs', 'app_log', _next_month);
    call sys.ensure_monthly_partition('logs', 'auth_log', _next_month);
end;
$$;
