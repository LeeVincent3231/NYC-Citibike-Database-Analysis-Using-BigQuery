-- identify stations with ridership exceeding the average daily trips across the system
SELECT
start_station_name,
ROUND(AVG(tripduration),2) AS average_trip_length
FROM `bigquery-public-data.new_york.citibike_trips`
GROUP BY 1
ORDER BY average_trip_length DESC;
