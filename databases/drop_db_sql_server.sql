-- Check active sessions
SELECT *
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('NomeBanco')

-- Kill active sessions
KILL 68 -- Substitute pelo ID da sessão que deseja

-- Drop database
USE [master]
GO
DROP DATABASE [NomeBanco]
GO