EXEC xp_cmdshell 'bcp "select * from AdventureWorks2025.raw.customer" queryout "C:\temp\customer.csv" -c -t, -r \n -T -S "BOOK3-ULTRA"'; 
