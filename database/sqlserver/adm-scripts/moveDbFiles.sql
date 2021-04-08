USE master
-- INDEX
ALTER DATABASE DB   
    MODIFY FILE ( NAME = DB_NDEX,   
                  FILENAME = 'I:\MSSQL13.MSSQLSERVER\MSSQL\INDEX\INDEX.mdf');  
GO
-- LOG
ALTER DATABASE DB   
    MODIFY FILE ( NAME = DB_log,   
                  FILENAME = 'L:\MSSQL13.MSSQLSERVER\MSSQL\Log\DB_log.ldf');  
GO
-- DATA
ALTER DATABASE DB   
    MODIFY FILE ( NAME = DB,   
                  FILENAME = 'D:\MSSQL13.MSSQLSERVER\MSSQL\DATA\DB.mdf');  
GO


ALTER DATABASE DB SET OFFLINE;
GO
ALTER DATABASE DB SET ONLINE; 
GO

SELECT name, physical_name AS NewLocation, state_desc AS OnlineStatus
FROM sys.master_files  
WHERE database_id = DB_ID(N'DB')  