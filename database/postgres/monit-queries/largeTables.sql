SELECT  schemaname, tablename,
        pg_size_pretty(pg_relation_size(esq_tab)) AS size,
        pg_size_pretty(pg_total_relation_size(esq_tab)) AS total_size
FROM    (   SELECT  tablename, schemaname, schemaname||'.'||tablename AS sch_tab
            FROM    pg_catalog.pg_tables
            WHERE   schemaname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')) AS tmp
ORDER   BY pg_total_relation_size(sch_tab) DESC;