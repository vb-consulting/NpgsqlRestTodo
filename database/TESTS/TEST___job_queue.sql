do
$$
declare
    _record record;
    _now timestamptz = '2020-01-01 00:00:00';
    _job_id bigint;
    _job_id2 bigint;
    _job_id3 bigint;
    _dequeued_count integer;
    _dequeued_job record;
    _worker_id bigint;
    _test_payload jsonb = '{"task": "test_task", "data": "test_data"}'::jsonb;
    _batch_results record;
    _result boolean;
begin
    -- mock the now setting for this test transaction
    call sys.set_current_setting('sys.now', _now::text);
    
    -- Store the transaction ID for later use
    _worker_id = txid_current();
    
    -- Test 1: Enqueue a job
    _job_id = app.enqueue_job(_test_payload);
    assert _job_id is not null, 'Failed to enqueue job';
    
    -- Verify job was created with correct status and values
    select * into _record from job_queue where job_queue_id = _job_id;
    assert _record.status = 'pending', 'Expected status to be pending, got ' || _record.status;
    assert _record.payload = _test_payload, 'Payload mismatch';
    assert _record.scheduled_for = _now, 'scheduled_for time mismatch';
    assert _record.locked_by is null, 'Expected locked_by to be null';
    
    -- Test 2: Dequeue a job
    _dequeued_count = 0;
    for _dequeued_job in select * from app.dequeue_job() loop
        _dequeued_count = _dequeued_count + 1;
        assert _dequeued_job.job_queue_id = _job_id, 'Dequeued wrong job ID';
    end loop;
    assert _dequeued_count = 1, 'Expected to dequeue 1 job, got ' || _dequeued_count;
    
    -- Verify job status was updated
    select * into _record from job_queue where job_queue_id = _job_id;
    assert _record.status = 'processing', 'Expected status to be processing after dequeue, got ' || _record.status;
    assert _record.locked_by = _worker_id, 'Expected locked_by to match transaction ID';
    assert _record.attempts = 1, 'Expected attempts to be 1, got ' || _record.attempts;
    
    -- Test 3: Complete a job
    _result = app.complete_job(_job_id);
    assert _result = true, 'Expected complete_job to return true';
    
    -- Verify completion status
    select * into _record from job_queue where job_queue_id = _job_id;
    assert _record.status = 'completed', 'Expected status to be completed after completion, got ' || _record.status;
    assert _record.completed_at = _now, 'Completed_at time mismatch';
    assert _record.locked_by is null, 'Expected locked_by to be null after completion';
    
    -- Test 4: Fail a job with retry
    _job_id2 = app.enqueue_job(_test_payload);
    perform app.dequeue_job();
    
    -- Set now time ahead to verify scheduled_for gets updated
    _now = _now + interval '5 minutes';
    call sys.set_current_setting('sys.now', _now::text);
    
    _result = app.fail_job(_job_id2, txid_current(), interval '10 minutes');
    assert _result = true, 'Expected fail_job to return true';
    
    -- Verify job is rescheduled
    select * into _record from job_queue where job_queue_id = _job_id2;
    assert _record.status = 'pending', 'Expected status to be pending after failure with retry, got ' || _record.status;
    assert _record.scheduled_for = _now + interval '10 minutes', 'scheduled_for time not updated correctly';
    assert _record.locked_by is null, 'Expected locked_by to be null after failure';
    
    -- Test 5: Max attempts reached (job should be marked as failed)
    _job_id3 = app.enqueue_job(_test_payload, 0, _now, 1); -- max_attempts = 1
    
    -- Dequeue and fail the job to reach max attempts
    perform app.dequeue_job();
    _result = app.fail_job(_job_id3);
    
    -- Verify job is marked as failed
    select * into _record from job_queue where job_queue_id = _job_id3;
    assert _record.status = 'failed', 'Expected status to be failed after max attempts, got ' || _record.status;

    truncate table job_queue;
    
    -- Test 6: Jobs are dequeued by priority order
    _now = _now + interval '1 hour';
    call sys.set_current_setting('sys.now', _now::text);
    
    -- Create jobs with different priorities
    _job_id = app.enqueue_job('{"task":"low_priority"}'::jsonb, -1);
    _job_id2 = app.enqueue_job('{"task":"high_priority"}'::jsonb, 10);
    _job_id3 = app.enqueue_job('{"task":"medium_priority"}'::jsonb, 5);
    
    -- Dequeue one job and verify it's the highest priority
    _dequeued_job = null;
    for _record in select * from app.dequeue_job(txid_current(), 1) loop
        _dequeued_job = _record;
        exit; -- Only need the first one
    end loop;
    
    assert _dequeued_job is not null, 'Expected to dequeue at least one job';
    assert _dequeued_job.payload->>'task' = 'high_priority', 
        'Expected to dequeue high priority job first, got ' || (_dequeued_job.payload->>'task');
    
    -- Test 7: Batch dequeuing
    -- Dequeue the remaining jobs and verify the order by priority
    _dequeued_count = 0;
    for _dequeued_job in select * from app.dequeue_job(txid_current(), 10) loop
        _dequeued_count = _dequeued_count + 1;
        
        if _dequeued_count = 1 then
            assert _dequeued_job.payload->>'task' = 'medium_priority', 
                'Expected medium priority job second, got ' || (_dequeued_job.payload->>'task');
        elsif _dequeued_count = 2 then
            assert _dequeued_job.payload->>'task' = 'low_priority', 
                'Expected low priority job last, got ' || (_dequeued_job.payload->>'task');
        end if;
    end loop;
    
    assert _dequeued_count = 2, 'Expected to dequeue 2 more jobs, got ' || _dequeued_count;
    
    -- Test 8: Future scheduled jobs
    _now = _now + interval '2 hours';
    call sys.set_current_setting('sys.now', _now::text);
    
    -- Create a job scheduled for future
    _job_id = app.enqueue_job(_test_payload, 0, _now + interval '1 hour');
    
    -- Attempt to dequeue
    _dequeued_count = 0;
    for _dequeued_job in select * from app.dequeue_job() loop
        _dequeued_count = _dequeued_count + 1;
    end loop;
    assert _dequeued_count = 0, 'Expected no jobs to be dequeued (future scheduled job)';
    
    -- Fast forward time
    _now = _now + interval '2 hours';
    call sys.set_current_setting('sys.now', _now::text);
    
    -- Now the job should be available
    _dequeued_count = 0;
    for _dequeued_job in select * from app.dequeue_job() loop
        _dequeued_count = _dequeued_count + 1;
    end loop;
    assert _dequeued_count = 1, 'Expected to dequeue future job after time passed';
    
    -- Test 9: Test worker ID isolation
    _job_id = app.enqueue_job(_test_payload);
    
    -- Simulate another worker trying to complete the job
    perform app.dequeue_job(_worker_id);
    _result = app.complete_job(_job_id, _worker_id + 1);
    
    assert _result = false, 'Expected complete_job to return false with wrong worker ID';
    
    select * into _record from job_queue where job_queue_id = _job_id;
    assert _record.status = 'processing', 'Expected status to still be processing with wrong worker ID';
    
    -- Proper worker completes the job
    _result = app.complete_job(_job_id, _worker_id);
    assert _result = true, 'Expected complete_job to return true with correct worker ID';
    
    -- All tests passed
    raise notice 'All queue tests passed successfully!';
    
    ROLLBACK;
end;
$$;

-- reset job_queue_id sequence
select setval('job_queue_job_queue_id_seq', coalesce((select max(job_queue_id) from job_queue) + 1, 1), false);

