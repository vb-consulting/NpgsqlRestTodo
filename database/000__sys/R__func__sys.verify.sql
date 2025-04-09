call sys.drop('sys.verify');

create function sys.verify(
    _input text,
    _hash bytea
)
returns boolean
parallel safe
language sql
as
$$
select pgsodium.crypto_pwhash_str_verify(_hash, _input::bytea);
$$;
