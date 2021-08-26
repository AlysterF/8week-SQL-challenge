--A. Pizza Metrics

--How many pizzas were ordered?
SELECT
  COUNT(*) AS pizzas_ordered
FROM
  pizza_runner.customer_orders;

--How many unique customer orders were made?
SELECT
  COUNT(DISTINCT order_id) AS orders_made
FROM
  pizza_runner.customer_orders;

--How many successful orders were delivered by each runner?
SELECT
  COUNT(DISTINCT co.order_id) AS successful_orders
FROM
  pizza_runner.customer_orders co
JOIN
  pizza_runner.runner_orders ro ON ro.order_id = co.order_id
WHERE
  cancellation IS NULL;

--How many of each type of pizza was delivered?
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

--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
  pn.pizza_name,
  COUNT(co.pizza_id) AS total_orders
FROM
  pizza_runner.customer_orders co
JOIN
  pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
GROUP BY
  pn.pizza_name;

--What was the maximum number of pizzas delivered in a single order?

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

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

--How many pizzas were delivered that had both exclusions and extras?
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

--What was the total volume of pizzas ordered for each hour of the day?
SELECT
  EXTRACT(HOUR FROM order_time) AS hour_of_day,
  COUNT(pizza_id) AS qty_pizzas
FROM
  pizza_runner.customer_orders
GROUP BY
  hour_of_day
ORDER BY
  hour_of_day;

--What was the volume of orders for each day of the week?
SELECT
  EXTRACT(DOW FROM order_time) AS week_day,
  COUNT(pizza_id) AS qty_pizzas
FROM
  pizza_runner.customer_orders
GROUP BY
  week_day
ORDER BY
  week_day;