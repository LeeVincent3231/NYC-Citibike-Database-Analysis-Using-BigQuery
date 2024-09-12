-- Visualize total trips per date based on avg rain and snow conditions
SELECT weather.DATE, COUNT(trips) as total_trips, AVG(PRCP) as rain, AVG(SNOW) as snow
FROM `bana-279-project-416801.nyccitibike.citibike_trips` AS trips
INNER JOIN `bana-279-project-416801.nyccitibike.NYC Weather` AS weather
ON DATE(trips.starttime) = weather.DATE
GROUP BY weather.DATE
ORDER BY weather.DATE;


-- Visualize total trips per station based on avg rain and snow conditions
SELECT start_station_name,
COUNT(CASE WHEN SNOW > 0 THEN 1 ELSE NULL END) AS trips_with_snow, -- Count trips with snow
COUNT(CASE WHEN SNOW = 0 THEN 1 ELSE NULL END) AS trips_no_snow, -- Count trips without snow
COUNT(CASE WHEN PRCP > 0 THEN 1 ELSE NULL END) AS trips_with_rain, -- Count trips with rain
COUNT(CASE WHEN PRCP = 0 THEN 1 ELSE NULL END) AS trips_no_rain, -- Count trips without rain
COUNT(*) AS total_trips -- Total trips at the station
FROM `bana-279-project-416801.nyccitibike.citibike_trips` AS trips
INNER JOIN `bana-279-project-416801.nyccitibike.NYC Weather` AS weather
ON DATE(trips.starttime) = weather.DATE
GROUP BY start_station_name;
