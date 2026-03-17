bcp "SELECT * FROM dbo.Sales" queryout "C:\Temp\Sales.csv" -c -t"," -S "your-server.database.windows.net" -d "your_database" -U "your_db_username" -P "your_password"
