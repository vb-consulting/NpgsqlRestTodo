/*
Parse regclass table name to schema and table name array
*/
create function _.parse_regclass_name(
    _name regclass
)
returns text[]
language plpgsql
stable
parallel safe
as
$$
begin
    if position('.' in _name::text) = 0 then
        return array['public', _name::text];
    else
        return array[split_part(_name::text, '.', 1), split_part(_name::text, '.', 2)];
    end if;
end;
$$;
