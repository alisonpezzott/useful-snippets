-- DROP EXTERNAL DATA SOURCE ds_blob
-- DROP DATABASE SCOPED CREDENTIAL cred_blob
-- DROP MASTER KEY

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YOUR_MASTER_KEY';

CREATE DATABASE SCOPED CREDENTIAL cred_blob
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2025-10-13T11:13:18Z&se=2025-10-13T19:28:18Z&spr=https&sv=2024-11-04&sr=c&sig=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

CREATE EXTERNAL DATA SOURCE ds_blob
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://your_blob.blob.core.windows.net/your_container',
    CREDENTIAL = cred_blob
)

BULK INSERT dbo.customer
FROM 'customer.csv'                   
WITH (
    DATA_SOURCE     = 'ds_blob_contoso',
    FIRSTROW        = 1,             
    FIELDTERMINATOR = ',',           
    ROWTERMINATOR   = '0x0A',         
    CODEPAGE        = '1251',        
    TABLOCK
)
