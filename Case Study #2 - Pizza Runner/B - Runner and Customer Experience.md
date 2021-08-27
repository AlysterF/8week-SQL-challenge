## B. Runner and Customer Experience 🛵👥

**Query #01**

How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

In this query I had to convert the date into week using to_char function, once dates in PostgreSQL are according to ISO8601.
When using WOY to extract the week of year, sometimes if the first day of the year is part of the last week of the last year, the week will be consider as 52 or 53, depending of the year, and using to_char function I avoid this kind of overlaping.

````sql
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
````

***Output***

| week | new_runners |
| ---- | ----------- |
| 01   | 2           |
| 02   | 1           |
| 03   | 1           |


---
**Query #02**

What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

In this calculation I broke the date into two parts: the hours and minutes. I could use the day if it was applicaple, but I know the difference between the two timestamps are not longer than hours.

````sql
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
````

***Output***

| runner_id | avg_minutes_to_pickup |
| --------- | --------------------- |
| 1         | 15.33                 |
| 2         | 23.40                 |
| 3         | 10.00                 |

---
**Query #03**

Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
````

***Output***

| qty_pizzas | avg_prep_time |
| ---------- | ------------- |
| 1          | 12            |
| 2          | 18            |
| 3          | 29            |


Notice that the average preparation time is higher when we have more pizzas in the order. And it really make sense, right?
It's curious that the average difference between 1 and 2 pizzas are only 6 minutes, and when the order has 3, the prep time increase considerably. Maybe the pizza company can only bake two pizzas at the same time. It would be something to think about :)


---
**Query #04**

What was the average distance travelled for each customer?

````sql
    SELECT
      co.customer_id,
      ROUND(CAST(AVG(ro.distance) AS DECIMAL),2) AS avg_distance_km
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.runner_orders ro ON ro.order_id = co.order_id
    GROUP BY co.customer_id
    ORDER BY co.customer_id;
````

***Output***

| customer_id | avg_distance_km |
| ----------- | --------------- |
| 101         | 20.00           |
| 102         | 16.73           |
| 103         | 23.40           |
| 104         | 10.00           |
| 105         | 25.00           |

---
**Query #05**

What was the difference between the longest and shortest delivery times for all orders?

````sql
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
````

***Output***

| max_min_diff_delivery |
| --------------------- |
| 44                    |


---
**Query #06**

What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
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
````

***Output***

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


It looks like the runners increase their average speed in each order.
It's difficult to know why, once we don't know if they're using another route, or the customer ordered for a different destination and etc. Too many possible variables! It would be great to explore more about it though!


---
**Query #07**

What is the successful delivery percentage for each runner?

````sql
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
````

***Output***

| runner_id | total_deliveries | successful_deliveries | perc_successful |
| --------- | ---------------- | --------------------- | --------------- |
| 3         | 2                | 1                     | 0.50            |
| 2         | 4                | 3                     | 0.75            |
| 1         | 4                | 4                     | 1.00            |

The percentage here is not formatted as percentual value, it's a decimal value :)
I choose this format thinking about the future use of data, per example, in dataviz tools. It's usually easier to work with decimals in those tools.

---

[View Original Schema on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
