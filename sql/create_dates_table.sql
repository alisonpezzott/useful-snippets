CREATE TABLE dbo.dates (
    [date]         DATE        NOT NULL PRIMARY KEY,
    [year]         SMALLINT    NOT NULL,
    [month]        TINYINT     NOT NULL,
	  [month_name]   VARCHAR(12) NOT NULL,
    [day]          TINYINT     NOT NULL
);
GO

DECLARE @start_date DATE = '2022-01-01';
DECLARE @end_date DATE = DATEFROMPARTS(YEAR(GETDATE()), 12, 31);

;WITH cte AS (
    SELECT @start_date AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM cte
    WHERE d < @end_date
)
INSERT INTO dbo.dates ([date], [year], [month], [month_name], [day])
SELECT
    d,
    YEAR(d),
    MONTH(d),
	FORMAT(d, 'MMM', 'en-US'),
    DAY(d)
FROM cte
OPTION (MAXRECURSION 0);
GO
