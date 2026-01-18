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


Invoke-Sqlcmd -ServerInstance "YourServer" `
    -Database "YourDatabase" `
    -Username "YourUser" `
    -Password "YourPassword" `
    -Query ("SELECT customer_id, first_name, middle_name, last_name, address_line_1, " +
			"addess_line_2, city, state_province_code, country_region_code, " +
			"state_name, territory_name, territory_group, " +
			"CONVERT(varchar(10), start_date, 23) AS start_date, " + 
			"CONVERT(varchar(10), end_date, 23)   AS end_date,  " +  
			"is_active " +
			"FROM raw.customer ") `
    -TrustServerCertificate | Export-Csv -Path "C:\temp\customer.csv" `
    -Delimiter ";" `
    -NoTypeInformation
