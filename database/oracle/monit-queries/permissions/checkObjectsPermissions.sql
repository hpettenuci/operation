SELECT  dbo.object_name, 
        dbo.object_type, 
        dbo.status, 
        dtp.grantee, 
        dtp.privilege
FROM    dba_objects dbo
LEFT    JOIN dba_tab_privs dtp 
            ON  dbo.owner = dtp.owner 
            AND dbo.object_name = dtp.table_name
WHERE   dbo.owner = '<DB SCHEMA>'
AND     dbo.object_type NOT IN ('INDEX', 'LOB','TRIGGER','TYPE')
AND     dtp.grantee IS NULL
ORDER   BY dbo.object_type, dbo.object_name, dtp.grantee;