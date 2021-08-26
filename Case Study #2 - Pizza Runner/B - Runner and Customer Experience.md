## B. Runner and Customer Experience

**Query #20**

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

| week | new_runners |
| ---- | ----------- |
| 01   | 2           |
| 02   | 1           |
| 03   | 1           |

---
**Query #21**

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

| runner_id | avg_minutes_to_pickup |
| --------- | --------------------- |
| 1         | 15.33                 |
| 2         | 23.40                 |
| 3         | 10.00                 |

---
**Query #22**

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

| qty_pizzas | avg_prep_time |
| ---------- | ------------- |
| 1          | 12            |
| 2          | 18            |
| 3          | 29            |

---
**Query #23**

    SELECT
      co.customer_id,
      ROUND(CAST(AVG(ro.distance) AS DECIMAL),2) AS avg_distance_km
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.runner_orders ro ON ro.order_id = co.order_id
    GROUP BY co.customer_id
    ORDER BY co.customer_id;

| customer_id | avg_distance_km |
| ----------- | --------------- |
| 101         | 20.00           |
| 102         | 16.73           |
| 103         | 23.40           |
| 104         | 10.00           |
| 105         | 25.00           |

---
**Query #24**

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

| max_min_diff_delivery |
| --------------------- |
| 44                    |

---
**Query #25**

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

| runner_id | order_id | distance_km | duration_minutes | avg_speed_kmh |
| --------- | -------- | ----------- | ---------------- | ------------- |
| 1         | 1        | 20          | 32               | 37.50         |
| 1         | 2        | 20          | 27               | 44.44         |
| 1         | 3        | 13.4        | 20               | 40.20         |
| 1         | 10       | 10          | 10               | 60.00         |
| 2         | 4        | 23.4        | 40               | 35.10         |
| 2         | 7        | 25          | 25               | 60.00         |
| 2         | 8        | 23.4        | 15               | 93.60         |
| 3         | 5        | 10          | 15               | 40.00         |

---
**Query #26**

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

| runner_id | total_deliveries | successful_deliveries | perc_successful |
| --------- | ---------------- | --------------------- | --------------- |
| 3         | 2                | 1                     | 0.50            |
| 2         | 4                | 3                     | 0.75            |
| 1         | 4                | 4                     | 1.00            |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
