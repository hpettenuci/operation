SELECT  dbschemas.[name] AS Schema,
        dbtables.[name] AS Table,
        dbindexes.[name] AS Index,
        indexstats.avg_fragmentation_in_percent,
        indexstats.page_count
FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER   JOIN sys.tables  dbtables   ON  dbtables.[object_id] = indexstats.[object_id]
INNER   JOIN sys.schemas dbschemas  ON  dbschemas.[schema_id] = dbtables.[schema_id]
INNER   JOIN sys.indexes dbindexes  ON  dbindexes.[object_id] = indexstats.[object_id]
                                    AND indexstats.index_id = dbindexes.index_id
WHERE   indexstats.database_id = DB_ID()
ORDER   BY indexstats.avg_fragmentation_in_percent DESC