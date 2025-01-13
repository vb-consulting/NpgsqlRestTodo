call sys.drop('sys.add_jsonb_key');

create function sys.add_jsonb_key(
    _data jsonb,
    _key text,
    _value text,
    _if_null text = ''
)
returns jsonb
language sql
immutable
parallel safe
as
$$
select coalesce(_data, '{}')::jsonb || jsonb_build_object(_key, coalesce(_value, _if_null));
$$;
