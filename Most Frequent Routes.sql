-- Identifying most frequent routes
WITH ranked_routes AS (
SELECT start_station_name, end_station_name, COUNT(*) AS trip_count
FROM `bigquery-public-data.new_york.citibike_trips` as trips
GROUP BY start_station_name, end_station_name
ORDER BY trip_count DESC
LIMIT 10
)
SELECT s1.name AS start_station, s2.name AS end_station, trip_count
FROM ranked_routes
INNER JOIN `bigquery-public-data.new_york.citibike_stations` AS s1 ON ranked_routes.start_station_name = s1.name
INNER JOIN `bigquery-public-data.new_york.citibike_stations` AS s2 ON ranked_routes.end_station_name = s2.name
ORDER BY trip_count DESC;
