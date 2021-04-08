SELECT s.schemaname,
       s.relname AS tablename,
       s.indexrelname AS indexname,
       s.idx_scan,
       pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
       ix.indexdef || ';' as create_statment,
       'DROP INDEX IF EXISTS ' || s.indexrelname || ';' as drop_statment
FROM pg_catalog.pg_stat_user_indexes s
   JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
   JOIN pg_indexes ix on s.schemaname = ix.schemaname and s.relname = ix.tablename and s.indexrelname = ix.indexname
WHERE s.idx_scan < 10      -- has rarely scanned
  AND 0 <>ALL (i.indkey)  -- no index column is an expression
  AND NOT i.indisunique   -- is not a UNIQUE index
  AND NOT EXISTS          -- does not enforce a constraint
         (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;