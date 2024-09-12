SELECT weekday, COUNT(*) as trip_count
FROM (
SELECT *,
CASE
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 1 THEN 'Monday'
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 2 THEN 'Tuesday'
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 3 THEN 'Wednesday'
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 4 THEN 'Thursday'
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 5 THEN 'Friday'
WHEN EXTRACT(DAYOFWEEK FROM CAST(starttime AS DATE)) = 6 THEN 'Saturday'
ELSE 'Sunday'
END AS weekday
FROM `bigquery-public-data.new_york.citibike_trips`
) as subquery
GROUP BY weekday
ORDER BY
CASE weekday
WHEN 'Monday' THEN 1
WHEN 'Tuesday' THEN 2
WHEN 'Wednesday' THEN 3
WHEN 'Thursday' THEN 4
WHEN 'Friday' THEN 5
WHEN 'Saturday' THEN 6
ELSE 7 -- Ensure Sunday is last
END;
