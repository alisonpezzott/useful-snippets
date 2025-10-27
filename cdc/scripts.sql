ALTER TABLE dbo.Customer
ALTER COLUMN CustomerKey INT NOT NULL;

CREATE UNIQUE INDEX IX_Customer_Unique
ON dbo.Customer (CustomerId, CustomerVersion); 

EXEC sys.sp_cdc_enable_db;

EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name = N'Customer',
@role_name = NULL,
@index_name = N'IX_Customer_Unique',
@supports_net_changes = 1;

SELECT name, is_cdc_enabled FROM sys.databases;
SELECT name, is_tracked_by_cdc FROM sys.tables;

DROP INDEX IX_Customer_Unique on dbo.Customer;
