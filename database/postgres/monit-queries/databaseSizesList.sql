SELECT  pg_database.datname AS database_name, 
        (pg_stat_file('base/'||oid ||'/PG_VERSION')).modification AS last_modification,
        pg_size_pretty(pg_database_size(pg_database.datname)) AS db_size
FROM    pg_database 
ORDER   BY db_size DESC;