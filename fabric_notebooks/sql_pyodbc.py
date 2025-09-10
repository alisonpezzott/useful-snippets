import pyodbc

# Get the secret value from Key Vault
clientId = "<clientId>" 
tenantId = "<tenantId>"
principalSecret = mssparkutils.credentials.getSecret("https://<keyValutName>.vault.azure.net/", "<secretName>")  

# SQL Server connection details
server = "<SQL Endpoint FQDN>"
database = "<database>"
username = f"{principalId}@{tenantId}"

# Connection string with the access token
connection_string = f"Driver={{ODBC Driver 18 for SQL Server}};Server={server};Database={database};Authentication=ActiveDirectoryServicePrincipal;UID={username};PWD={principalSecret};ConnectRetryCount=4"
# print(connection_string)

# Connect to the Azure SQL Database using pyodbc
conn = pyodbc.connect(connection_string)

# Execute a query
query = "select count(*) from table"
cursor = conn.cursor()
cursor.execute(query)

# Fetch all rows
rows = cursor.fetchall()

# Print the rows
for row in rows:
    print(row)

# Close the connection
conn.close()
