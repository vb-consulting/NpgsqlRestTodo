
call sys.drop('sys.generate_rnd_code');

create or replace function sys.generate_rnd_code(
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
    if _length < 6 then
        raise exception 'Confirmation code must be at least 6 characters long for security';
    end if;
    
    if not _include_numbers and not _include_letters then
        raise exception 'At least one character type (numbers or letters) must be included';
    end if;
    
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
