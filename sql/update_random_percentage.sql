UPDATE t
SET percentage_discount =
    CASE 
        WHEN rnd.pick <= 0.5 THEN
            CASE rnd.bucket
                WHEN 0 THEN 0.05
                WHEN 1 THEN 0.10
                WHEN 2 THEN 0.15
                ELSE 0.20
            END
        ELSE 0
    END
FROM dbo.table_name t
CROSS APPLY (
    SELECT
        ABS(CHECKSUM(NEWID())) % 4 AS bucket,  -- 0 a 3
        CAST(ABS(CHECKSUM(NEWID())) AS float) / 2147483647 AS pick
) rnd;
