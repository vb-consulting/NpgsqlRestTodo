call sys.drop('sys.annotate');

/*
This is a helper procedure to add comment annotations to functions or procedures.
First argument is the name of the function or procedure without parameters with schema name included.

Instead:    comment on procedure schema.name(parm1 text, param2 int) is 'multiline comment text';
Use this:   call sys.annotate('schema.name', 'line1', 'line2', 'line1', 'line3');

This call will add the same comment to all overload versions of the same fucntion or procedure.

During development process, parameters are changed somtimes often. 
This procedure solves to problem of having to change parameter list on call comment on procedure schema.name(parm1 text, param2 int) 

Comment annotations can enable/disable/alter behavior on NpgsqlRest server. See: https://vb-consulting.github.io/npgsqlrest/annotations/
*/
create procedure sys.annotate(
    _name regproc,
    variadic _annotations text[]
)
language plpgsql
as 
$$
declare 
    _rec record;
    _cmd text;
    _executed boolean = false;
    _nspname name;
    _proname name;
begin
    if position('.' in _name::text) = 0 then
        _nspname = 'public';
        _proname = _name::text;
    else
        _nspname = split_part(_name::text, '.', 1);
        _proname = split_part(_name::text, '.', 2);
    end if;
    for _rec in (
        select p.oid::regprocedure::text as proc, p.prokind as kind
        from pg_proc p join pg_namespace n 
        on p.pronamespace = n.oid and n.nspname = _nspname and proname = _proname
        where p.prokind in ('f', 'p')
    )
    loop
        if _rec.kind = 'f' then
            _cmd = 'comment on function ' || _rec.proc || ' is ' || quote_literal(array_to_string(_annotations, E'\n'));
        elsif _rec.kind = 'p' then
            _cmd = 'comment on procedure ' || _rec.proc || ' is ' || quote_literal(array_to_string(_annotations, E'\n'));
        else
            continue;
        end if;

        raise info '%', _cmd;
        execute _cmd;
        _executed = true;
    end loop;

    if not _executed then
        raise exception 'Function or procedure "%" does not exist', _name;
    end if;
end;
$$;
