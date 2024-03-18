    SELECT *
    FROM (
        SELECT *, row_number()
        OVER (
            PARTITION BY ticker, dimension, calendardate, datekey, reportperiod
            ORDER BY lastupdated DESC
        ) 
        FROM sharadar.sf1
    ) as bs
    WHERE row_number = 1
    AND dimension = 'ARQ'
