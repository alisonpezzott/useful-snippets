bcp "SELECT * FROM dbo.Sales" queryout "C:\Temp\Sales.csv" -c -C 65001 -t";" -S "your-server.database.windows.net" -d "your_database" -U "your_db_username" -P "your_password"

bcp "dbo.Sales" in "C:\Temp\Sales.csv" -c -C 65001 -t";" -S "your-server.database.windows.net" -d "your_database" -U "your_db_username" -P "your_password"
