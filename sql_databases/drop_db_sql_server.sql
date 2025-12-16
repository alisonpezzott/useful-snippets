USE master;
GO

DECLARE @database NVARCHAR(128) = 'Sandbox';
DECLARE @sql NVARCHAR(MAX);

-- Check active sessions
SELECT session_id, login_name, host_name, program_name, status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID(@database);

-- Kill active sessions
SET @sql = '';
SELECT @sql = @sql + 'KILL ' + CAST(session_id AS VARCHAR(10)) + '; '
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID(@database)
  AND session_id <> @@SPID; -- Don't kill your own session

-- Execute kill commands
IF @sql <> ''
BEGIN
    EXEC sp_executesql @sql;
END

-- Drop database
SET @sql = 'DROP DATABASE ' + QUOTENAME(@database);
EXEC sp_executesql @sql;
GO
