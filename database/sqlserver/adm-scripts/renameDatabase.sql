USE [master];
GO
ALTER DATABASE "[DATABASE_NAME]" SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
EXEC sp_renamedb N'[DATABASE_OLD_NAME]', N'[DATABASE_NEW_NAME]';

-- Add users again
ALTER DATABASE "[DATABASE_NEW_NAME]" SET MULTI_USER
GO