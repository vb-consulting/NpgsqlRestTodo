create type auth.login_response as (
    status int,
    scheme text,
    user_id text, 
    user_name text,
    user_roles text[],
    message json,
    hash text
);

create function auth.create_login_response(
    _success boolean = false,
    _id bigint = null,
    _name text = null,
    _roles text[] = null,
    _hash text = null
)
returns auth.login_response
language plpgsql
as
$$
begin
    return row(
        case when _success is true then 200 else 404 end, 
        case when _success is true then auth.setting('default_scheme') else null end,
        case when _success is true then _id::text else null end, -- user_id
        case when _success is true then _name else null end,
        case when _success is true then _roles else null end,
        case when _success is true then json_build_object('id', _id::text, 'name', _name, 'roles', _roles) else null end,
        case when _success is true then _hash else null end
    )::auth.login_response;
end
$$;