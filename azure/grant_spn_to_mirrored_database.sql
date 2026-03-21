-- If not exists
CREATE USER [AppFabric] FOR LOGIN [AppFabric];
GO


GRANT SELECT TO [AppFabric];
GRANT ALTER ANY EXTERNAL MIRROR TO [AppFabric];
GRANT VIEW DATABASE PERFORMANCE STATE TO [AppFabric];
GRANT VIEW DATABASE SECURITY STATE TO [AppFabric];
GO


-- Other util queries
SELECT name, type_desc
FROM sys.database_principals
WHERE name = 'alison.pezzott@overdax.com';

CREATE USER [alison.pezzott@overdax.com] FROM EXTERNAL PROVIDER;
GO

ALTER ROLE db_datareader ADD MEMBER [alison.pezzott@overdax.com];
GO

ALTER ROLE db_datawriter ADD MEMBER [alison.pezzott@overdax.com];
GO

ALTER ROLE db_owner ADD MEMBER [alison.pezzott@overdax.com];
GO

GRANT ALTER ANY EXTERNAL MIRROR TO [AppFabric];
GRANT VIEW DATABASE PERFORMANCE STATE TO [AppFabric];
GRANT VIEW DATABASE SECURITY STATE TO [AppFabric];
