/*
Drop functions or procedures by name.
This procedure accepts a variadic array of function or procedure names in the format 'schema.name'.
It will drop each function or procedure if it exists, and raise a warning if it does not exist.
The procedure supports both functions and procedures, identified by their `prokind` in the `pg_proc` table.
The `prokind` can be 'f' for function or 'p' for procedure.
If the function or procedure is successfully dropped, an informational message is raised.
If the function or procedure does not exist, a warning is raised.
*/
create procedure _.drop(
    variadic _names text[]
) 
language plpgsql
set search_path = public, pg_catalog
as 
$$
declare 
    _name text;
    _rec record;
    _cmd text;
    _executed boolean;
begin
    foreach _name in array _names loop
        _executed = false;
        for _rec in (
            select p.oid::regprocedure::text as proc, p.prokind as kind
            from pg_catalog.pg_proc p join pg_catalog.pg_namespace n 
            on p.pronamespace = n.oid and n.nspname = split_part(_name, '.', 1) and proname = split_part(_name, '.', 2)
            where p.prokind in ('f', 'p')
        )
        loop
            if _rec.kind = 'f' then
                _cmd = 'drop function ' || _rec.proc;
            elsif _rec.kind = 'p' then
                _cmd = 'drop procedure ' || _rec.proc;
            else
                continue;
            end if;
            raise info '%', _cmd;
            execute _cmd;
            _executed = true;
        end loop;

        if not _executed then
            raise warning 'Function or procedure "%" does not exist', _name;
        end if;
    end loop;
end;
$$;
