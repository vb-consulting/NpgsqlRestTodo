create type auth.register_response as (
    code int,
    message text
);

create function auth.create_register_response(
    _code int,
    _message text
)
returns auth.register_response
language sql
as
$$
select (_code, _message)::auth.register_response;
$$;