## A. Pizza Metrics 🍕
---
**Query #01**

How many pizzas were ordered?

````sql
    SELECT
      COUNT(*) AS pizzas_ordered
    FROM
      pizza_runner.customer_orders;
````

***Output***

| pizzas_ordered |
| -------------- |
| 14             |


---
**Query #02**

How many unique customer orders were made?

````sql
    SELECT
      COUNT(DISTINCT order_id) AS orders_made
    FROM
      pizza_runner.customer_orders;
````

***Output***

| orders_made |
| ----------- |
| 10          |


---
**Query #03**

How many successful orders were delivered by each runner?

````sql
    SELECT
      COUNT(DISTINCT co.order_id) AS successful_orders
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.runner_orders ro ON ro.order_id = co.order_id
    WHERE
      cancellation IS NULL;
````

***Output***

| successful_orders |
| ----------------- |
| 8                 |


---
**Query #04**

How many of each type of pizza was delivered?

````sql
    WITH delivered_pizzas AS(
      SELECT
        pizza_id
      FROM
        pizza_runner.customer_orders co
      JOIN
        pizza_runner.runner_orders ro ON ro.order_id = co.order_id
      WHERE
        cancellation IS NULL
    )
    SELECT
      pizza_id,
      COUNT(pizza_id) AS total_orders
    FROM
      delivered_pizzas
    GROUP BY
      pizza_id;
````

***Output***

| pizza_id | total_orders |
| -------- | ------------ |
| 1        | 9            |
| 2        | 3            |


---
**Query #05**

How many Vegetarian and Meatlovers were ordered by each customer?

````sql
    SELECT
      pn.pizza_name,
      COUNT(co.pizza_id) AS total_orders
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
    GROUP BY
      pn.pizza_name;
````

***Output***

| pizza_name | total_orders |
| ---------- | ------------ |
| Meatlovers | 10           |
| Vegetarian | 4            |


---
**Query #06**

What was the maximum number of pizzas delivered in a single order?

````sql
    WITH pizzas_per_order AS(
      SELECT
        order_id,
        COUNT(pizza_id) AS qty_pizzas
      FROM
        pizza_runner.customer_orders
      GROUP BY
        order_id
    )
    
    SELECT
      MAX(qty_pizzas) AS qty_pizzas
    FROM
      pizzas_per_order;
````

***Output***


| qty_pizzas |
| ---------- |
| 3          |


---
**Query #07**

For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
    WITH count_changes AS(
      SELECT co.customer_id,
      CASE
            WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 'Changed'
            ELSE 'Not Changed'
      END AS changes
      FROM
        pizza_runner.customer_orders co
      JOIN
        pizza_runner.runner_orders ro ON ro.order_id = co.order_id
      WHERE
        ro.cancellation IS NULL
    )
    
    SELECT
      customer_id,
      changes,
      COUNT(*) AS qty_pizzas
    FROM
      count_changes
    GROUP BY
      customer_id, changes
    ORDER BY
      customer_id, changes;
````

***Output***

| customer_id | changes     | qty_pizzas |
| ----------- | ----------- | ---------- |
| 101         | Not Changed | 2          |
| 102         | Not Changed | 3          |
| 103         | Changed     | 3          |
| 104         | Changed     | 2          |
| 104         | Not Changed | 1          |
| 105         | Changed     | 1          |


---
**Query #08**

How many pizzas were delivered that had both exclusions and extras?

````sql
    SELECT
      COUNT(co.pizza_id) AS changed_pizza_delivered
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.runner_orders ro ON ro.order_id = co.order_id
    WHERE
      exclusions IS NOT NULL
      AND extras IS NOT NULL
      AND ro.cancellation IS NULL;
````

***Output***

| changed_pizza_delivered |
| ----------------------- |
| 1                       |


---
**Query #09**

What was the total volume of pizzas ordered for each hour of the day?

````sql
    SELECT
      EXTRACT(HOUR FROM order_time) AS hour_of_day,
      COUNT(pizza_id) AS qty_pizzas
    FROM
      pizza_runner.customer_orders
    GROUP BY
      hour_of_day
    ORDER BY
      hour_of_day;
````

***Output***

| hour_of_day | qty_pizzas |
| ----------- | ---------- |
| 11          | 1          |
| 13          | 3          |
| 18          | 3          |
| 19          | 1          |
| 21          | 3          |
| 23          | 3          |

---
**Query #10**

What was the volume of orders for each day of the week?

````sql
    SELECT
      EXTRACT(DOW FROM order_time) AS week_day,
      COUNT(pizza_id) AS qty_pizzas
    FROM
      pizza_runner.customer_orders
    GROUP BY
      week_day
    ORDER BY
      week_day;
````

***Output***

| week_day | qty_pizzas |
| -------- | ---------- |
| 3        | 5          |
| 4        | 3          |
| 5        | 1          |
| 6        | 5          |

---

[View the original schema on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
