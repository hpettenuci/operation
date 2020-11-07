SELECT
        --pg_terminate_backend(pid) AS session_closed, -- uncomment to kill session
        (NOW() - query_start) AS period_running,
        *
FROM    pg_stat_activity 
WHERE   datname = '<DATABASE NAME>'
AND     pid <> pg_backend_pid()
AND     state = 'active'
AND     usename not in ('') -- ignore user list
AND     (NOW() - query_start) > '00:05:00.000000' -- min period to filter 
ORDER   BY query_start;