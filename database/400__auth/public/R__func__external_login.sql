call sys.drop('auth.external_login');

create function auth.external_login(
    _email text,
    _name text,
    _analytics_data jsonb = '{}'
)
returns auth.login_response
security definer
language plpgsql
as
$$
begin

end
$$;
