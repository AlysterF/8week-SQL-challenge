--B. Runner and Customer Experience

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--in this script, I had to extract the week using to_char function, once the extract() or date_part() with week uses ISO 8601 and sometimes, the week overlaps with the last week of the year before.
WITH registration_weeks AS (
  SELECT
    runner_id,
    to_char(registration_date, 'WW') AS week
  FROM pizza_runner.runners
)
SELECT
  week,
  COUNT(DISTINCT runner_id) AS new_runners
FROM
  registration_weeks
GROUP BY week
ORDER BY week;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH pickup_analysis AS(
  SELECT
    ro.order_id,
    ro.runner_id, 
    (DATE_PART('hour', ro.pickup_time - co.order_time) * 60
    + DATE_PART('minute', ro.pickup_time - co.order_time)) AS minutes_to_pickup
  FROM
    pizza_runner.runner_orders ro
  JOIN
    pizza_runner.customer_orders co ON co.order_id = ro.order_id
)

SELECT
  runner_id,
  ROUND(CAST(AVG(minutes_to_pickup) AS DECIMAL), 2) AS avg_minutes_to_pickup
FROM
  pickup_analysis
GROUP BY runner_id
ORDER BY runner_id;

--Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH prep_time AS(
  SELECT
    ro.order_id,
    COUNT(co.pizza_id) AS qty_pizzas,
    (DATE_PART('hour', ro.pickup_time - co.order_time) * 60
    + DATE_PART('minute', ro.pickup_time - co.order_time)) AS prep_time
  FROM
    pizza_runner.runner_orders ro
  JOIN
    pizza_runner.customer_orders co ON co.order_id = ro.order_id
  GROUP BY
    ro.order_id,
    prep_time
)

SELECT
  qty_pizzas,
  AVG(prep_time) AS avg_prep_time
FROM
  prep_time
GROUP BY qty_pizzas
ORDER BY qty_pizzas;

--What was the average distance travelled for each customer?
SELECT
  co.customer_id,
  ROUND(CAST(AVG(ro.distance) AS DECIMAL),2) AS avg_distance_km
FROM
  pizza_runner.customer_orders co
JOIN
  pizza_runner.runner_orders ro ON ro.order_id = co.order_id
GROUP BY co.customer_id
ORDER BY co.customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
WITH delivery_time AS(
  SELECT
  (DATE_PART('hour', ro.pickup_time - co.order_time) * 60
  + DATE_PART('minute', ro.pickup_time - co.order_time)
  + ro.duration) AS delivery_time
  FROM
    pizza_runner.runner_orders ro
  JOIN
    pizza_runner.customer_orders co ON co.order_id = ro.order_id
)
SELECT
  MAX(delivery_time) - MIN(delivery_time) AS max_min_diff_delivery
FROM
  delivery_time;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
  runner_id,
  order_id,
  distance AS distance_km,
  duration AS duration_minutes,
  ROUND(CAST(distance/duration*60 AS DECIMAL), 2) AS avg_speed_kmh
FROM
  pizza_runner.runner_orders
WHERE
  cancellation IS NULL
ORDER BY
  runner_id,
  order_id;

--What is the successful delivery percentage for each runner?
WITH deliveries AS (
  SELECT
    runner_id,
    COUNT(order_id) AS total_deliveries,
    SUM(
        CASE
        WHEN cancellation IS NOT NULL THEN 0
          ELSE 1
        END
      ) AS successful_deliveries
  FROM
    pizza_runner.runner_orders
  GROUP BY
    runner_id
)
SELECT
  *,
  ROUND((successful_deliveries::DECIMAL/total_deliveries::DECIMAL),2) AS perc_successful
FROM
  deliveries;