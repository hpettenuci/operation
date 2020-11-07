SELECT  pg_terminate_backend(pg_stat_activity.pid) 
FROM    pg_stat_activity 
WHERE   pid <> pg_backend_pid() 
AND     pg_stat_activity.datname = '<CURENT DB NAME>';

ALTER DATABASE <CURENT DB NAME> rename TO <NEW DB NAME>;