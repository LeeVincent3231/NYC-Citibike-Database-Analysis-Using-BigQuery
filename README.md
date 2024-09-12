## Table of Contents
1. [NYC Citibike Database Design and Analysis Using BigQuery](#nyc-citibike-database-design-and-analysis-using-bigquery)
2. [Tools and Frameworks](#tools-and-frameworks)
3. [Data Source](#data-source)
4. [Dataset Schemas](#dataset-schemas)
5. [Database Design](#database-design)
6. [Insightful SQL Queries Driving Operational Insights](#insightful-sql-queries-driving-operational-insights)
    - [Identifying Most Frequent Routes](#identifying-most-frequent-routes)
    - [Identifying Stations with Longest Average Trip Durations](#identifying-stations-with-longest-average-trip-durations)
    - [Trip Counts per Day of the Week](#trip-counts-per-day-of-the-week)
    - [Ridership Based on Weather Data Queries](#ridership-based-on-weather-data-queries)
7. [Data Visualization Using Looker](#data-visualization-using-looker)
8. [Conclusion and Further Work](#conclusion-and-further-work)

# NYC Citibike Database Design and Analysis Using BigQuery
This project applies database management and design principles along with developing SQL queries using BigQuery to analyze NYC Citibike's dataset. The goal is to practice database design concepts and design effective queries to provide insights into user behaviour, bike station efficiencies, and how external factors like weather may impact ridership.

# Tools and Frameworks
- **Google BigQuery** for developing and storing queries on the datasets
- **SQL** for creating queries
- **Looker** for creating visualizations based on query results
- **ERD Diagrams** and **Database Relational Tables** for illustrating the data model

# Data Source
NYC Citibike dataset is pubicily available on the BigQuery platform: https://console.cloud.google.com/marketplace/product/city-of-new-york/nyc-citi-bike?hl=en-GB

# Dataset Schemas
The NYC Citibike dataset contains two tables.

**citibike_stations**
| Field Name                 | Mode      | Type      | Description                                                                 |
|----------------------------|-----------|-----------|-----------------------------------------------------------------------------|
| station_id                 | REQUIRED  | STRING    | Unique identifier of a station.                                              |
| name                       | NULLABLE  | STRING    | Public name of the station.                                                  |
| short_name                 | NULLABLE  | STRING    | Short name or other type of identifier, as used by the data publisher.       |
| latitude                   | NULLABLE  | FLOAT     | The latitude of station. The field value must be a valid WGS 84 latitude in decimal degrees format. |
| longitude                  | NULLABLE  | FLOAT     | The longitude of station. The field value must be a valid WGS 84 longitude in decimal degrees format. |
| region_id                  | NULLABLE  | INTEGER   | ID of the region where station is located.                                   |
| rental_methods             | NULLABLE  | STRING    | Array of enumerables containing the payment methods accepted at this station. |
| capacity                   | NULLABLE  | INTEGER   | Number of total docking points installed at this station, both available and unavailable. |
| eightd_has_key_dispenser    | NULLABLE  | BOOLEAN   |                                                                             |
| num_bikes_available        | NULLABLE  | INTEGER   | Number of bikes available for rental.                                        |
| num_bikes_disabled         | NULLABLE  | INTEGER   | Number of disabled bikes at the station.                                     |
| num_docks_available        | NULLABLE  | INTEGER   | Number of docks accepting bike returns.                                      |
| num_docks_disabled         | NULLABLE  | INTEGER   | Number of empty but disabled dock points at the station.                     |
| is_installed               | NULLABLE  | BOOLEAN   | Is the station currently on the street?                                      |
| is_renting                 | NULLABLE  | BOOLEAN   | Is the station currently renting bikes?                                      |
| is_returning               | NULLABLE  | BOOLEAN   | Is the station accepting bike returns?                                       |
| eightd_has_available_keys  | NULLABLE  | BOOLEAN   |                                                                             |
| last_reported              | NULLABLE  | TIMESTAMP | Timestamp indicating the last time this station reported its status to the backend, in NYC local time. |

**citibike_trips**
| Field Name                 | Mode      | Type      | Description                                                                 |
|----------------------------|-----------|-----------|-----------------------------------------------------------------------------|
| tripduration               | NULLABLE  | INTEGER   | Trip Duration (in seconds)                                                  |
| starttime                  | NULLABLE  | DATETIME  | Start Time, in NYC local time.                                               |
| stoptime                   | NULLABLE  | DATETIME  | Stop Time, in NYC local time.                                                |
| start_station_id           | NULLABLE  | INTEGER   | Start Station ID                                                            |
| start_station_name         | NULLABLE  | STRING    | Start Station Name                                                          |
| start_station_latitude     | NULLABLE  | FLOAT     | Start Station Latitude                                                      |
| start_station_longitude    | NULLABLE  | FLOAT     | Start Station Longitude                                                     |
| end_station_id             | NULLABLE  | INTEGER   | End Station ID                                                              |
| end_station_name           | NULLABLE  | STRING    | End Station Name                                                            |
| end_station_latitude       | NULLABLE  | FLOAT     | End Station Latitude                                                        |
| end_station_longitude      | NULLABLE  | FLOAT     | End Station Longitude                                                       |
| bikeid                     | NULLABLE  | INTEGER   | Bike ID                                                                     |
| usertype                   | NULLABLE  | STRING    | User Type (Customer = 24-hour pass or 7-day pass user, Subscriber = Annual Member) |
| birth_year                 | NULLABLE  | INTEGER   | Year of Birth                                                               |
| gender                     | NULLABLE  | STRING    | Gender (unknown, male, female)                                               |
| customer_plan              | NULLABLE  | STRING    | The name of the plan that determines the rate charged for the trip           |

# Database Design
Below is a theoretical database structure design where hypothetical entities are created based on the NYC Citibike dataset. Several attributes (e.g. station_id, name, trip_duration) are part of the real dataset, while more attributes (e.g. trip_id, report_category, damage_history) were created to support a holistic picture of what the database should look like.
### Entities and Attributes Overview
- **Bike Station**: station_id, name, capacity, num_bikes_available, num_docks_available, rental_methods
- **Trip**: trip_id, trip_duration, start_time, stop_time, start_station_id, end_station_id, bike_id, user_id
- **User**: user_id, user_name, birth_year, gender, user_type, customer_plan, total_trips
- **Bike Equipment**: bike_id, bike_model, manufacturing_date, mileage, range, damage_history, maintenance_history
- **Feedback**: report_id, user_id, bike_id, trip_id, report_category, report_date, report_method
- **Payment (Associative Entity)**: transaction_id, rate, promo_code, payment_method, refund

### ERD Diagram
<img src="https://github.com/user-attachments/assets/1cddac71-9c45-4e68-a303-379322378078" width="700">

### Relational Database Tables
<img src="https://github.com/user-attachments/assets/3a92dee3-c716-49c9-a305-5c04dd21c557" width=700>

# Insightful SQL Queries Driving Operational Insights
In addition to the database design conducted, several queries were developed by querying the dataset through Google BigQuery studio. Below are the insights gained from the queries.

### Identifying Most Frequent Routes 
<details>
  <summary>View Query</summary>
  
  ```sql
  WITH ranked_routes AS (
    SELECT
        start_station_name,
        end_station_name,
        COUNT(*) AS trip_count
    FROM `bigquery-public-data.new_york.citibike_trips` as trips
    GROUP BY start_station_name, end_station_name
    ORDER BY trip_count DESC
    LIMIT 10
  )
  SELECT
      s1.name AS start_station,
        s2.name AS end_station,
        trip_count
  FROM ranked_routes
  INNER JOIN `bigquery-public-data.new_york.citibike_stations` AS s1 
      ON ranked_routes.start_station_name = s1.name
  INNER JOIN `bigquery-public-data.new_york.citibike_stations` AS s2 
      ON ranked_routes.end_station_name = s2.name
  ORDER BY trip_count DESC;
  ```
</details>

![image](https://github.com/user-attachments/assets/405be956-8be7-4c44-a3f9-3fdeca33eeb1)

**Insights**
- Identify high-volume routes: The top 3 popular routes start and end at the same station, indicating high cycling activity, particularly in recreational areas like Central Park, suggesting the need to ensure adequate bike availability.
- Optimize resource allocation: Understanding ridership patterns helps NYC Bike focus on maintaining and expanding popular routes, ensuring stations in high-demand areas have sufficient bicycles available.
- Support expansion and marketing efforts: Insights into popular routes and rider demographics can inform the addition of new stations and targeted promotions to enhance rider convenience and encourage increased usage.

### Identifying Stations with Longest Average Trip Durations 
Note that the durations are measured in seconds.
<details>
  <summary>View Query</summary>
  
  ```sql
  SELECT
    start_station_name,
    ROUND(AVG(tripduration),2) AS average_trip_length
  FROM `bigquery-public-data.new_york.citibike_trips`
  GROUP BY 1
  ORDER BY average_trip_length DESC;
  ```
</details>

![image](https://github.com/user-attachments/assets/fce2a508-2639-4664-b37f-17ea83dc9319)

**Insights**
- Identify potential docking imbalances: If stations consistently have long trip durations, it could indicate a one-way trip pattern. This could mean there's a shortage of bikes at the ending station, causing riders to take longer trips to return the bikes. NYC Bike can address this by rebalancing bikes between stations.
- Improve system planning: Understanding trip patterns can inform future expansion plans. If certain areas show high usage with long trips, NYC Bike could consider adding more stations or expanding service to those areas.
- Identify recreational areas: Stations with long trip durations could be located near recreational areas like parks or greenways. NYC Bike can use this data to partner with local authorities to improve cycling infrastructure in these areas.

### Trip Counts per Day of the Week
<details>
  <summary>View Query</summary>

  ```sql
  SELECT
    weekday,
    COUNT(*) as trip_count
  FROM (
    SELECT
      *,
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
    END
  ;
  ```
</details>

![image](https://github.com/user-attachments/assets/590cda5b-4661-4dcd-bd86-b3ed31445efe)

**Insights**
- Optimize Staffing: By understanding ridership patterns, NYC Bike can strategically staff stations based on expected customer volume. This ensures a smooth operation, especially during peak ridership times on weekdays.
- Schedule Maintenance Wisely: The data allows NYC Bike to schedule maintenance and repairs at stations with lower ridership. This minimizes service disruptions for riders. Sun & Mon, with their lower usage, might be a good time for such activities.
- Target Marketing Efforts: NYC Bike can target marketing campaigns towards specific weekdays. For example, they could offer promotions or discounts to encourage ridership on Sun & Mon when usage is lower.

### Ridership Based on Weather Data Queries
The queries integrate NYC government's weather dataset available here for public access: https://www.ncdc.noaa.gov/cdo-web/datasets/GHCND/stations/GHCND:USW00094728/detail

The NYC weather dataset contains over 124 columns of weather data, from variables such as snow, rain, air quality, and so on. We merge the datasets using INNER JOIN on the date column. 

**Total Trips Based on Avg Rain and Snow Conditions**
<details>
  <summary>View Query</summary>

  ```sql
  SELECT
    weather.DATE,
    COUNT(trips) as total_trips,
    AVG(PRCP) as rain,
    AVG(SNOW) as snow
  FROM `bana-279-project-416801.nyccitibike.citibike_trips` AS trips
  INNER JOIN `bana-279-project-416801.nyccitibike.NYC Weather` AS weather
  ON DATE(trips.starttime) = weather.DATE
  GROUP BY weather.DATE
  ORDER BY weather.DATE;
  ```
</details>

![image](https://github.com/user-attachments/assets/b19f56f3-c99a-4d0a-af9c-ffef0c8b0c38)

**Total Trips per Station Based on Avg Rain and Snow Conditions**
<details>
  <summary>View Query</summary>

  ```sql
  SELECT
    start_station_name,
    COUNT(CASE WHEN SNOW > 0 THEN 1 ELSE NULL END) AS trips_with_snow, -- Count trips with snow
    COUNT(CASE WHEN SNOW = 0 THEN 1 ELSE NULL END) AS trips_no_snow, -- Count trips without snow
    COUNT(CASE WHEN PRCP > 0 THEN 1 ELSE NULL END) AS trips_with_rain, -- Count trips with rain
    COUNT(CASE WHEN PRCP = 0 THEN 1 ELSE NULL END) AS trips_no_rain, -- Count trips without rain
    COUNT(*) AS total_trips -- Total trips at the station
  FROM `bana-279-project-416801.nyccitibike.citibike_trips` AS trips
  INNER JOIN `bana-279-project-416801.nyccitibike.NYC Weather` AS weather
  ON DATE(trips.starttime) = weather.DATE
  GROUP BY start_station_name;
  ```
</details>

![image](https://github.com/user-attachments/assets/d5d0b6e1-96ef-4c9c-9801-2c24040f74c9)

**Insights**
- Identify weather-affected stations: Analyzed stations where ridership is most impacted by adverse weather conditions, revealing areas with reduced activity during rain or snow.
- Address infrastructure needs: Stations with below-average ridership in bad weather signal the need for improved, weather-proof infrastructure to maintain service levels.
- Optimize bike availability: Stations with high ridership during ideal weather highlight the importance of ensuring sufficient bike availability during peak conditions.

# Data Visualization Using Looker


# Conclusion and Further Work
This project demonstrates a high-level application of database management systems design, data analysis through BigQuery SQL queries, and data visualization using Looker. All of these concepts combined produced valuable insights to improve operational efficency for NYC Citibike, such as identifying target stations with resource deficiencies or identifying marketing oppportunities based on route usage.

Further research could implement more datasets on top of weather data. For example, events data is another critical factor in assessing ridership, as certain city events can encourage more ridership. 

