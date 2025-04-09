create function sys.queue_stats()
returns table (
    status char(1),
    count bigint,
    oldest_job timestamptz,
    newest_job timestamptz
) 
language sql 
as 
$$
select status, count(*), min(created_at), max(created_at)
from job_queue
group by status;
$$;
