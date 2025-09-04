-- This snippet creates a query to rename the schema of all tables of a database

-- This query generates a query of various 'alter schema'
SELECT 
    'ALTER SCHEMA NewSchemaName TRANSFER ' + s.name + '.' + t.name + ';' AS [Script]
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'OldSchemaName'; 


-- For this example this query was generated from Data to dbo
ALTER SCHEMA dbo TRANSFER Data.CurrencyExchange;
ALTER SCHEMA dbo TRANSFER Data.Customer;
ALTER SCHEMA dbo TRANSFER Data.Date;
ALTER SCHEMA dbo TRANSFER Data.Product;
ALTER SCHEMA dbo TRANSFER Data.Store;
ALTER SCHEMA dbo TRANSFER Data.Sales;
ALTER SCHEMA dbo TRANSFER Data.Orders;
ALTER SCHEMA dbo TRANSFER Data.OrderRows;