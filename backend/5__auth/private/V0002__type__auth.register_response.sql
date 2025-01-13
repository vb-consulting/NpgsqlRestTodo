create type auth.login_response as (
    status int,
    scheme text,
    name_identifier text, 
    name text,
    role text[],
    message json
);