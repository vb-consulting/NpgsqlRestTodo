call sys.drop('sys.get_partition_range');

create function sys.get_partition_range(
    _name regclass
)
returns table (
    partition text,
    partition_range text,
    partition_from timestamptz,
    partition_to timestamptz
)
language sql
as 
$$
with _cte as (
    select 
        child.oid::regclass::text as partition,
        pg_get_expr(child.relpartbound, child.oid) as range
    from 
        pg_inherits
        join pg_class parent on parent.oid = pg_inherits.inhparent
        join pg_class child on child.oid = pg_inherits.inhrelid
    where 
        parent.oid = _name
)
select 
    a.partition,
    a.range, 
    substring(
        a.range 
        from 'FROM \(''([^'']+)''\)'
    )::timestamptz as partition_from,
    substring(
        a.range 
        from 'TO \(''([^'']+)''\)'
    )::timestamptz as partition_to
from _cte a;
$$;
