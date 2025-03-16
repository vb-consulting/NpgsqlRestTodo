call sys.drop('pages.index');

create function pages.index(
    _user_id text = null,
    _build_id text = null
)
returns text
language sql
immutable
as
$$
select format($html$<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title></title>
    <link href="/style.css?%1$s" rel="stylesheet" />
    <link href="/index.css?%1$s" rel="stylesheet" />
    <script>window.user = {id: {_user_id}, name: {_user_name}, roles: {_user_roles}};</script>
    <script defer src="/index.js?%1$s"></script>
</head>
<body></body>
</html>$html$, _build_id);
$$;

call sys.annotate('pages.index', 
    'HTTP GET /', 
    'Content-Type: text/html', 
    'allow-anonymous',
    'cached _user_id',
    'parse-response'
);
