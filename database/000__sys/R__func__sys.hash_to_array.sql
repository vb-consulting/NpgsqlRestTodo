call sys.drop('sys.hash_to_array');

create function sys.hash_to_array(
    _input text,
    _max_len int = 70
)
returns text[]
parallel safe
language plpgsql
as
$$
declare
    _segment text;
    _result text[] = '{}';
    _alg text = 'bf';
    _i int;
begin
    for _i in 0..ceil(length(_input) / _max_len) + 1 loop
        _segment = substring(_input from _i * _max_len + 1 for _max_len);
        if length(_segment) > 0 then
            _result = array_append(_result, crypt(_segment, gen_salt(_alg)));
        end if;
    end loop;

    return _result;
end;
$$;
