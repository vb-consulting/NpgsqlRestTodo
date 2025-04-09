call sys.drop('sys.verify_array');

create function sys.verify_array(
    _input text,
    _array text[],
    _max_len int = 70
)
returns boolean
parallel safe
language plpgsql
as
$$
declare
    _segment text;
    _result boolean = true;
begin
    for _i in 0..ceil(length(_input) / _max_len) + 1 loop
        _segment = substring(_input from _i * _max_len + 1 for _max_len);
        if length(_segment) > 0 then
            if crypt(_segment, _array[_i+1]) <> _array[_i+1] then
                -- we don't want to exit early, and check every segment to prevent timing attacks
                _result = false;
            end if;
        end if;
    end loop;
    return _result;
end;
$$;
