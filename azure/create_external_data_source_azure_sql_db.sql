CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YOUR_STRONG_PASSWORD';

CREATE DATABASE SCOPED CREDENTIAL your_credential_name
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
     SECRET = 'YOUR_SAS_TOKEN_like_sv=2025-07-05&XXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

CREATE EXTERNAL DATA SOURCE your_data_source_name
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://your_storage_account_name.blob.core.windows.net',
    CREDENTIAL = your_credential_name
);

BULK INSERT dbo.your_table
FROM 'your_path/your_file.csv'            
WITH (
    DATA_SOURCE = 'your_data_source_name',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1                    -- 2 if headers
);

