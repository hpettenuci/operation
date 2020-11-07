SELECT  tablespace_name, 
        (SUM(bytes)/1024/1024) AS sizeInMB
FROM    dba_segments 
GROUP   BY tablespace_name 
ORDER   BY SUM(bytes);