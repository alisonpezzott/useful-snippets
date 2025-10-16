DECLARE @SchemaName sysname = N'protheus';
DECLARE @sql nvarchar(max);

SELECT @sql = STRING_AGG(
    'SELECT N' + QUOTENAME(t.TABLE_NAME, '''') + ' AS Tabela, COUNT(*) AS TotalLinhas
     FROM ' + QUOTENAME(t.TABLE_SCHEMA) + '.' + QUOTENAME(t.TABLE_NAME),
    CHAR(10) + 'UNION ALL' + CHAR(10)
)
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_SCHEMA = @SchemaName
  AND t.TABLE_TYPE = 'BASE TABLE';

EXEC sp_executesql @sql;
