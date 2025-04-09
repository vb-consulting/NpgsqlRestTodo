/*
Trigger function to update audit updated_at and updated_at fields in a table automatically.
*/
create function _.audit_update_trigger()
returns trigger
language plpgsql
as
$$
declare
    _audit_columns text[] = TG_ARGV::text[];
begin
    if 'updated_at' = any(_audit_columns) then
        NEW.updated_at = now();
    end if;

    if 'updated_by' = any(_audit_columns) then
        NEW.updated_by = _.user_id();
    end if;

    return NEW;
end;
$$;
