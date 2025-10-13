Run in prompt

```
bcp "SELECT OrderKey, LineNumber, OrderDate, DeliveryDate, CustomerKey, StoreKey, ProductKey, Quantity, UnitPrice, NetPrice, UnitCost FROM ContosoV2.Data.Sales" queryout "C:\temp\sales.csv" -c -t, -T -S PEZZOTT

bcp "SELECT ProductKey, ProductCode, ProductName, Manufacturer, Brand, Color, CategoryName, SubCategoryName FROM ContosoV2.Data.Product" queryout "C:\temp\product.csv" -c -t, -T -S PEZZOTT

bcp "SELECT StoreKey, StoreCode, CountryName, State, OpenDate, CloseDate, Description, Status FROM ContosoV2.Data.Store" queryout "C:\temp\store.csv" -c -t, -T -S PEZZOTT

bcp "SELECT CustomerKey, UPPER( LEFT(Gender, 1) ) AS Gender, CONCAT_WS(' ', GivenName, MiddleInitial, Surname) AS Name, City, StateFull AS State, CountryFull AS Country, Birthday FROM ContosoV2.Data.Customer ORDER BY CustomerKey" queryout "C:\temp\customer.csv" -c -t, -T -S PEZZOTT

bcp "SELECT Date, DateKey, Year, YearMonth, YearMonthShort, YearMonthNumber, Month, MonthShort, MonthNumber, DayofWeek, DayofWeekShort, DayofWeekNumber FROM ContosoV2.Data.Date ORDER BY Date" queryout "C:\temp\date.csv" -c -t, -T -S PEZZOTT
```
