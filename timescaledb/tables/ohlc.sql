-- OHLC DATA VIEW
SELECT ticker, date, open, high, low, close, closeadj, closeunadj, volume
FROM (
    SELECT *, row_number()
    OVER (
        PARTITION BY ticker, date 
        ORDER BY lastupdated DESC
    ) 
    FROM sharadar.sep
) as ohlc
WHERE row_number = 1
