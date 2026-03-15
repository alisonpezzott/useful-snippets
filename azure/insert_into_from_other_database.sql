-- 1. Create master key if it does not exist
IF NOT EXISTS
(
    SELECT 1
    FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
) 
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'yourStrongPassword';
END
GO

-- 2. Create database scoped credential
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials
    WHERE name = 'Cred_contoso_pezzott'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL Cred_contoso_pezzott
    WITH IDENTITY = 'pezzott',
         SECRET = 'yourPassword';
END
GO

-- 3. Create external data source
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources
    WHERE name = 'EDS_contoso'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE EDS_contoso
    WITH
    (
        TYPE = RDBMS,
        LOCATION = 'pezzott-mvp.database.windows.net',
        DATABASE_NAME = 'contoso',
        CREDENTIAL = Cred_contoso_pezzott
    );
END
GO

-- 4. Create external table
IF OBJECT_ID('dbo.Store_ext', 'U') IS NULL
BEGIN
    CREATE EXTERNAL TABLE dbo.Store_ext
    (
	    [StoreKey] [int] NULL,
	    [StoreCode] [int] NULL,
	    [CountryName] [nvarchar](50) NULL,
	    [State] [nvarchar](100) NULL,
	    [OpenDate] [date] NULL,
	    [CloseDate] [date] NULL,
	    [Description] [nvarchar](100) NULL,
	    [Status] [nvarchar](50) NULL
    )
    WITH
    (
        DATA_SOURCE = EDS_contoso,
        SCHEMA_NAME = 'dbo',
        OBJECT_NAME = 'Store'
    );
END
GO

-- 5. Create local destination table if it does not exist
IF OBJECT_ID('dbo.Store', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Store
    (
	    [StoreKey] [int] NULL,
	    [StoreCode] [int] NULL,
	    [CountryName] [nvarchar](50) NULL,
	    [State] [nvarchar](100) NULL,
	    [OpenDate] [date] NULL,
	    [CloseDate] [date] NULL,
	    [Description] [nvarchar](100) NULL,
	    [Status] [nvarchar](50) NULL
    );
END
GO

-- 6. Copy data from external_table 
TRUNCATE TABLE dbo.Store;
GO

INSERT INTO dbo.Store 
(
  StoreKey,
  StoreCode,
  CountryName,
  State,
  OpenDate,
  CloseDate,
  Description,
  Status
)
SELECT 
  StoreKey,
  StoreCode,
  CountryName,
  State,
  OpenDate,
  CloseDate,
  Description,
  Status
FROM dbo.Store_ext;
GO
