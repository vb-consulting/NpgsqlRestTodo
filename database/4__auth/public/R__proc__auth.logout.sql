call _.drop('auth.logout');

create procedure auth.logout(
    _analytics jsonb = '{}'
) 
security definer
language plpgsql
as 
$$
declare
    _user_id bigint = _.user_id();
    _user_name text = _.user_name();
begin
    _analytics = _.append_ip_address(_analytics);
    call auth.log(
        'logout',
        true, 
        _user_name, 
        'Reset email enqueued.', 
        coalesce(_analytics, '{}'::jsonb) || jsonb_build_object('user_id', _user_id, 'username', _user_name)
    );
end;
$$;

call _.annotate('auth.logout', 
    'HTTP POST', 
    'anonymous',
    'logout',
    'security_sensitive'
);
