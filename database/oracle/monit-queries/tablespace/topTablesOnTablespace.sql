SELECT  table_name, 
        blocks 
FROM    dba_tables 
WHERE   tablespace_name = :tablespaceName
ORDER   BY blocks DESC;