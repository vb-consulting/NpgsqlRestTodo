/*
This is a helper procedure to be able to drop procedure or function (all overload versions) without specifying parameteres.
*/
create or replace procedure sys.drop(
    variadic _names text[]
) 
language plpgsql
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
            from pg_proc p join pg_namespace n 
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
