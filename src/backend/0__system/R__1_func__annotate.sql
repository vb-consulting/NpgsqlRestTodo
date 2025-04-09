call _.drop('_.annotate');

/*
Annotate functions or procedures with comments.
This procedure accepts a function or procedure name in the format 'schema.name' and a variadic array of annotations (comments), 
Each annotation in the array will be added as a new line of comment to the specified function or procedure.

Comment annotations can be used to provide metadata about the function or procedure to npgsqlrest server, such as HTTP methods, authorization requirements, or other relevant information.
If the comment annotation is not recognized by npgsqlrest, it will be ignored and used as a regular comment.
When comment annotations are added and recognized by npgsqlrest log will contain information about the annotations added to the function or procedure.

See more info at https://vb-consulting.github.io/npgsqlrest/annotations/
*/
create procedure _.annotate(
    _name regproc,
    variadic _annotations text[]
)
language plpgsql
set search_path = public, pg_catalog
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
        from pg_catalog.pg_proc p join pg_catalog.pg_namespace n 
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
