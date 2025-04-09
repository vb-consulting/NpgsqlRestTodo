/*
Execute a command with named parameters.

Example:
_.exec('create table %schema$I.%name$I ( -- );',
    'schema', _schema, 
    'name', _name
);
*/
create or replace procedure _.exec(
    _command text,
    variadic _args text[]
)
language plpgsql 
as
$$
declare
    _names text[] = array[]::text[];
    _values text[] = array[]::text[];
    i int;
    _muted constant boolean = _.setting('muted')::boolean;
begin
    for i in 1..array_length(_args, 1) by 2 loop
        _names = array_append(_names, _args[i]);
        _values = array_append(_values, _args[i+1]);
        _command = replace(_command, '%' || _args[i], '%' || array_length(_names, 1));
    end loop;
    _command = format(_command, variadic _values);
    if _muted is false then
        raise info '%', replace(_command, '    ', '');
    end if;

    execute _command;
end;
$$;
