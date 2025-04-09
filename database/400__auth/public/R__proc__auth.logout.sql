call sys.drop('auth.logout');

create procedure auth.logout(
    _user_id text,
    _user_name text,
    _analytics_data jsonb
) 
security definer
language plpgsql
as 
$$
begin
    call auth.log(
        'logout',
        true, 
        _email, 
        'Reset email enqueued.', 
        _analytics_data::jsonb || jsonb_build_object(
            'user_id', _user_id,
            'email', _user_name
        )
    );
end;
$$;

call sys.annotate('auth.logout', 
    'HTTP POST', 
    'Anonymous',
    'Logout'
);