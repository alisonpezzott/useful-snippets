# Run as admin

Install-Module -Name SqlServer -Force -AllowClobber

Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned

Import-Module SqlServer

Invoke-Sqlcmd -ServerInstance "YourServer" `
    -Database "YourDatabase" `
    -Username "YourUser" `
    -Password "YourPassword" `
    -Query ("SELECT OrderDate, CustomerKey, ProductKey, Quantity, UnitPrice " +
        "FROM sales " + 
        "WHERE OrderDate >= '2024-01-01' " + 
        "AND OrderDate <= '2024-12-31'") `
    -TrustServerCertificate | Export-Csv -Path "C:\temp\your_table.csv" `
    -Delimiter ";" `
    -NoTypeInformation
