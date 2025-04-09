create function temporal._temporal_history_before_trigger()
returns trigger
security definer
language plpgsql 
as
$$
begin
    raise exception '%', 
        format(
            'Table %1$I.%2$I is a history table and cannot be modified (or updated or deleted)', 
            TG_ARGV[0], 
            TG_ARGV[1]
        );
end;
$$;