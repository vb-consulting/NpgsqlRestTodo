
call _.drop('_.generate_rnd_code');

/*
Generate a random code of specified length.
*/
create function _.generate_rnd_code(
    _length int default 6,
    _include_numbers boolean default true,
    _include_letters boolean default true,
    _uppercase_only boolean default false
)
returns text
parallel safe
language plpgsql
as
$$
declare
    _numbers constant text = '0123456789';
    _uppercase_letters constant text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    _lowercase_letters constant text = 'abcdefghijklmnopqrstuvwxyz';
    _characters text = '';
    _code text = '';
    _i int = 0;
    _random_index int;
begin
    if _include_numbers then
        _characters = _characters || _numbers;
    end if;
    if _include_letters then
        _characters = _characters || _uppercase_letters;
        if not _uppercase_only then
            _characters = _characters || _lowercase_letters;
        end if;
    end if;
    
    while _i < _length loop
        -- gen_random_bytes is cryptographically secure
        _random_index = 1 + mod(get_byte(gen_random_bytes(1), 0), length(_characters));
        _code = _code || substr(_characters, _random_index, 1);
        _i = _i + 1;
    end loop;
    
    return _code;
end;
$$;
