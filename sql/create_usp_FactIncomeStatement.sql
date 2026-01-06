USE master;
GO

/* =========================================================
   1) usp_SaveDiscoveredSqlServers
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_SaveDiscoveredSqlServers
AS
BEGIN
    SET NOCOUNT ON;

    -- Create table if not exists
    IF NOT EXISTS (
        SELECT 1
        FROM sys.tables t
        JOIN sys.schemas s ON s.schema_id = t.schema_id
        WHERE t.name = 'SqlServerDiscovery'
          AND s.name = 'dbo'
    )
    BEGIN
        CREATE TABLE dbo.SqlServerDiscovery
        (
            discovery_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
            discovered_at      DATETIME2(0) NOT NULL 
                CONSTRAINT DF_SqlServerDiscovery_discovered_at 
                DEFAULT SYSUTCDATETIME(),

            server_raw         NVARCHAR(255) NULL,
            server_clean       NVARCHAR(255) NOT NULL,

            is_main            BIT NOT NULL,
            linked_server_name SYSNAME NULL,

            source_command     NVARCHAR(200) NOT NULL 
                CONSTRAINT DF_SqlServerDiscovery_source_command 
                DEFAULT ('sqlcmd -L'),

            CONSTRAINT UQ_SqlServerDiscovery_server_clean 
                UNIQUE (server_clean)
        );
    END;

    DECLARE @main_server_name SYSNAME = CAST(SERVERPROPERTY('ServerName') AS SYSNAME);

    CREATE TABLE #ServidoresSQL ([Server] NVARCHAR(255));

    INSERT INTO #ServidoresSQL ([Server])
    EXEC xp_cmdshell 'sqlcmd -L';

    ;WITH cleaned AS
    (
        SELECT
            server_raw   = [Server],
            server_clean = NULLIF(LTRIM(RTRIM([Server])), '')
        FROM #ServidoresSQL
    ),
    filtered AS
    (
        SELECT
            server_raw,
            server_clean,
            is_main = CASE WHEN server_clean = @main_server_name THEN 1 ELSE 0 END,
            linked_server_name =
                CASE
                    WHEN server_clean = @main_server_name THEN NULL
                    ELSE CAST(
                        TRANSLATE(
                            UPPER(server_clean),
                            '\./ -',
                            '_____'
                        ) AS SYSNAME
                    )
                END
        FROM cleaned
        WHERE server_clean IS NOT NULL
          AND server_clean NOT IN ('Servers:', '(local)')
          AND server_clean NOT LIKE 'NULL%'
    )
    MERGE dbo.SqlServerDiscovery AS T
    USING filtered AS S
        ON T.server_clean = S.server_clean
    WHEN MATCHED THEN
        UPDATE SET
            T.discovered_at      = SYSUTCDATETIME(),
            T.server_raw         = S.server_raw,
            T.is_main            = S.is_main,
            T.linked_server_name = S.linked_server_name
    WHEN NOT MATCHED THEN
        INSERT (server_raw, server_clean, is_main, linked_server_name)
        VALUES (S.server_raw, S.server_clean, S.is_main, S.linked_server_name);

    DROP TABLE #ServidoresSQL;
END;
GO

/* =========================================================
   2) usp_CreateLinkedServer
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_CreateLinkedServer
(
    @linked_server_name SYSNAME,
    @data_source        NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @linked_server_name)
    BEGIN
        PRINT 'Linked server already exists: ' + @linked_server_name;
        RETURN;
    END;

    EXEC master.dbo.sp_addlinkedserver
        @server     = @linked_server_name,
        @srvproduct = N'',
        @provider   = N'SQLNCLI',
        @datasrc    = @data_source,
        @provstr    = N'Encrypt=No';

    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='collation compatible', @optvalue='false';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='data access', @optvalue='true';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='dist', @optvalue='false';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='pub', @optvalue='false';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='rpc', @optvalue='true';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='rpc out', @optvalue='true';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='sub', @optvalue='false';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='connect timeout', @optvalue='0';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='collation name', @optvalue=NULL;
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='lazy schema validation', @optvalue='false';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='query timeout', @optvalue='0';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='use remote collation', @optvalue='true';
    EXEC master.dbo.sp_serveroption @server=@linked_server_name, @optname='remote proc transaction promotion', @optvalue='true';

    EXEC master.dbo.sp_addlinkedsrvlogin
        @rmtsrvname = @linked_server_name,
        @locallogin = NULL,
        @useself    = 'TRUE';

    PRINT 'Linked server created successfully: ' + @linked_server_name;
END;
GO

/* =========================================================
   3) usp_CreateLinkedServersFromDiscovery
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_CreateLinkedServersFromDiscovery
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @linked_server_name SYSNAME, @data_source NVARCHAR(255);

    DECLARE cur_servers CURSOR LOCAL FAST_FORWARD FOR
        SELECT linked_server_name, server_clean
        FROM dbo.SqlServerDiscovery
        WHERE is_main = 0
          AND linked_server_name IS NOT NULL;

    OPEN cur_servers;
    FETCH NEXT FROM cur_servers INTO @linked_server_name, @data_source;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = @linked_server_name)
        BEGIN
            EXEC dbo.usp_CreateLinkedServer
                @linked_server_name = @linked_server_name,
                @data_source        = @data_source;
        END;

        FETCH NEXT FROM cur_servers INTO @linked_server_name, @data_source;
    END;

    CLOSE cur_servers;
    DEALLOCATE cur_servers;
END;
GO

/* =========================================================
   4) usp_Rebuild_IncomeStatementColumns
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_Rebuild_IncomeStatementColumns
(
    @database SYSNAME = N'IncomeStatement',
    @schema   SYSNAME = N'dbo',
    @table    SYSNAME = N'FactIncomeStatement',
    @truncate BIT     = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    IF DB_ID(@database) IS NULL
    BEGIN
        DECLARE @msg NVARCHAR(2048) = N'Database not found: ' + QUOTENAME(@database);
        THROW 50010, @msg, 1;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.tables t
        JOIN sys.schemas s ON s.schema_id = t.schema_id
        WHERE t.name = 'IncomeStatementColumns'
          AND s.name = 'dbo'
    )
    BEGIN
        CREATE TABLE dbo.IncomeStatementColumns (
            ordinal       INT           NOT NULL PRIMARY KEY,
            column_name   SYSNAME       NOT NULL,
            sql_type      NVARCHAR(200) NOT NULL
        );
    END;

    IF @truncate = 1
        TRUNCATE TABLE dbo.IncomeStatementColumns;

    DECLARE @sql NVARCHAR(MAX) = N'
;WITH src AS
(
    SELECT
        c.column_id AS ordinal,
        c.name      AS column_name,
        CASE 
            WHEN t.name IN (''varchar'',''char'',''nvarchar'',''nchar'') 
                THEN t.name + ''('' + CASE WHEN c.max_length = -1 THEN ''MAX''
                                           WHEN t.name IN (''nvarchar'',''nchar'') THEN CAST(c.max_length / 2 AS VARCHAR(10))
                                           ELSE CAST(c.max_length AS VARCHAR(10)) END + '')''
            WHEN t.name IN (''decimal'',''numeric'')
                THEN t.name + ''('' + CAST(c.precision AS VARCHAR(10)) + '','' + CAST(c.scale AS VARCHAR(10)) + '')''
            WHEN t.name IN (''datetime2'',''time'',''datetimeoffset'')
                THEN t.name + ''('' + CAST(c.scale AS VARCHAR(10)) + '')''
            ELSE
                t.name
        END AS sql_type
    FROM ' + QUOTENAME(@database) + N'.sys.columns c
    JOIN ' + QUOTENAME(@database) + N'.sys.tables  tb ON tb.object_id = c.object_id
    JOIN ' + QUOTENAME(@database) + N'.sys.schemas sc ON sc.schema_id = tb.schema_id
    JOIN ' + QUOTENAME(@database) + N'.sys.types   t  ON t.user_type_id = c.user_type_id
    WHERE sc.name = ' + QUOTENAME(@schema, '''') + N'
      AND tb.name = ' + QUOTENAME(@table, '''') + N'
)
' + CASE 
        WHEN @truncate = 1 THEN
N'
INSERT INTO dbo.IncomeStatementColumns (ordinal, column_name, sql_type)
SELECT ordinal, column_name, sql_type
FROM src
ORDER BY ordinal;'
        ELSE
N'
MERGE dbo.IncomeStatementColumns AS T
USING src AS S
    ON T.ordinal = S.ordinal
WHEN MATCHED THEN
    UPDATE SET
        T.column_name = S.column_name,
        T.sql_type    = S.sql_type
WHEN NOT MATCHED THEN
    INSERT (ordinal, column_name, sql_type)
    VALUES (S.ordinal, S.column_name, S.sql_type)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;'
    END;

    EXEC sys.sp_executesql @sql;
END;
GO

/* =========================================================
   5) usp_Rebuild_vwFactIncomeStatement
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_Rebuild_vwFactIncomeStatement
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @database    SYSNAME = N'IncomeStatement',
        @view_schema SYSNAME = N'dbo',
        @view_name   SYSNAME = N'vwFactIncomeStatement',
        @src_schema  SYSNAME = N'dbo',
        @src_table   SYSNAME = N'FactIncomeStatement';

    DECLARE @select_cols NVARCHAR(MAX);

    SELECT @select_cols =
        STRING_AGG(
            N'CAST(t.' + QUOTENAME(c.column_name) + N' AS ' + c.sql_type + N') AS ' + QUOTENAME(c.column_name),
            N',' + CHAR(10) + N'    '
        ) WITHIN GROUP (ORDER BY c.ordinal)
    FROM dbo.IncomeStatementColumns c;

    IF @select_cols IS NULL
        THROW 50001, 'dbo.IncomeStatementColumns está vazia. Cadastre as colunas canônicas.', 1;

    IF OBJECT_ID('tempdb..#missing') IS NOT NULL DROP TABLE #missing;
    CREATE TABLE #missing (source_name SYSNAME NOT NULL, column_name SYSNAME NOT NULL);

    DECLARE @linked SYSNAME, @is_main BIT;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT linked_server_name, is_main
        FROM dbo.SqlServerDiscovery;

    OPEN cur;
    FETCH NEXT FROM cur INTO @linked, @is_main;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @prefix NVARCHAR(400) =
            CASE WHEN @is_main = 1
                 THEN QUOTENAME(@database) + N'.'
                 ELSE QUOTENAME(@linked) + N'.' + QUOTENAME(@database) + N'.'
            END;

        DECLARE @check_sql NVARCHAR(MAX) = N'
INSERT INTO #missing (source_name, column_name)
SELECT ' + QUOTENAME(COALESCE(@linked, CAST(SERVERPROPERTY('ServerName') AS SYSNAME)), '''') + N', c.column_name
FROM dbo.IncomeStatementColumns c
WHERE NOT EXISTS (
    SELECT 1
    FROM ' + @prefix + N'sys.columns sc
    JOIN ' + @prefix + N'sys.tables  st ON st.object_id = sc.object_id
    JOIN ' + @prefix + N'sys.schemas ss ON ss.schema_id = st.schema_id
    WHERE ss.name = ' + QUOTENAME(@src_schema, '''') + N'
      AND st.name = ' + QUOTENAME(@src_table, '''') + N'
      AND sc.name = c.column_name
);';

        EXEC sys.sp_executesql @check_sql;

        FETCH NEXT FROM cur INTO @linked, @is_main;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    IF EXISTS (SELECT 1 FROM #missing)
    BEGIN
        SELECT source_name, column_name
        FROM #missing
        ORDER BY source_name, column_name;

        THROW 50002, 'Um ou mais bancos não possuem todas as colunas canônicas. Veja o resultado acima.', 1;
    END;

    DECLARE @view_sql NVARCHAR(MAX);

    ;WITH src AS
    (
        SELECT
            is_main,
            linked_server_name,
            source_name = COALESCE(linked_server_name, CAST(SERVERPROPERTY('ServerName') AS SYSNAME))
        FROM dbo.SqlServerDiscovery
    )
    SELECT @view_sql =
        N'CREATE OR ALTER VIEW ' + QUOTENAME(@view_schema) + N'.' + QUOTENAME(@view_name) + N' AS' + CHAR(10) +
        STRING_AGG(
            CASE 
                WHEN is_main = 1 THEN
                    N'SELECT ' + QUOTENAME(source_name, '''') + N' AS [Database],' + CHAR(10) +
                    N'    ' + @select_cols + CHAR(10) +
                    N'FROM ' + QUOTENAME(@database) + N'.' + QUOTENAME(@src_schema) + N'.' + QUOTENAME(@src_table) + N' t'
                ELSE
                    N'SELECT ' + QUOTENAME(source_name, '''') + N' AS [Database],' + CHAR(10) +
                    N'    ' + @select_cols + CHAR(10) +
                    N'FROM ' + QUOTENAME(linked_server_name) + N'.' + QUOTENAME(@database) + N'.' + QUOTENAME(@src_schema) + N'.' + QUOTENAME(@src_table) + N' t'
            END,
            CHAR(10) + N'UNION ALL' + CHAR(10)
        )
    FROM src;

    IF @view_sql IS NULL
        THROW 50003, 'dbo.SqlServerDiscovery não retornou fontes para compor a view.', 1;

    EXEC sys.sp_executesql @view_sql;
END;
GO

/* =========================================================
   6) usp_Orchestrate_vwFactIncomeStatement
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_Orchestrate_vwFactIncomeStatement
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_SaveDiscoveredSqlServers;
    EXEC dbo.usp_CreateLinkedServersFromDiscovery;

    EXEC dbo.usp_Rebuild_IncomeStatementColumns
        @database = 'IncomeStatement',
        @schema   = 'dbo',
        @table    = 'FactIncomeStatement',
        @truncate = 0;

    EXEC dbo.usp_Rebuild_vwFactIncomeStatement;
END;
GO
