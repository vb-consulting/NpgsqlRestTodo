call sys.drop('auth.logout');

create procedure auth.logout(
    _user_id text = null,
    _user_name text = null,
    _analytics_data jsonb = '{}',
    _ip_address text = null
) 
security definer
language plpgsql
as 
$$
begin
    _analytics_data = sys.add_jsonb_key(_analytics_data, 'ip', _ip_address);
    call auth.log(
        'logout',
        true, 
        _user_name, 
        'Reset email enqueued.', 
        _analytics_data::jsonb || jsonb_build_object(
            'user_id', _user_id
        )
    );
end;
$$;

call sys.annotate('auth.logout', 
    'HTTP POST', 
    'Anonymous',
    'Logout',
    'SecuritySensitive'
);
