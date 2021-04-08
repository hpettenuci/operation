SELECT  grantee, 
        table_name,
        privilege, 
        grantable
FROM    DBA_TAB_PRIVS 
WHERE   grantee IN (SELECT granted_role FROM DBA_ROLE_PRIVS WHERE grantee = '&1')
ORDER   BY role, table_name;