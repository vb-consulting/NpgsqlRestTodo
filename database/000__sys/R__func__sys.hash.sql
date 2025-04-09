call sys.drop('sys.hash');

create function sys.hash(
    _input text
)
returns bytea
parallel safe
language sql
as
$$
select pgsodium.crypto_pwhash_str(_input::bytea);
$$;
