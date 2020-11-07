SELECT  *
FROM    (SELECT obj.name                AS table_name,
   		        SCHEMA_NAME(schema_id)  AS table_schema,
   		        idx.rowcnt         	    AS num_rows
   	    FROM    (SELECT DISTINCT id, rowcnt
   			    FROM    sys.sysindexes) idx
INNER   JOIN sys.objects obj on obj.object_id = idx.id) dtx
WHERE   UPPER(dtx.table_schema) = '<SCHEMA NAME>'
ORDER   BY num_rows DESC
