DECLARE @start_date DATETIME2 = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @end_date   DATETIME2 = DATEADD(DAY, 1, EOMONTH(GETDATE()));

SELECT 
    customer_id,
    product_id,
    CAST(order_date AS date) AS order_date,
    sales_amount
FROM fact_sales
WHERE order_date >= @start_date
  AND order_date < @end_date;
