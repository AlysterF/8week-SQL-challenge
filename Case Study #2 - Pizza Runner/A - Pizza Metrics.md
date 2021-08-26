## A. Pizza Metrics
---
**Query #20**

    SELECT
      COUNT(*) AS pizzas_ordered
    FROM
      pizza_runner.customer_orders;

| pizzas_ordered |
| -------------- |
| 14             |

---
**Query #21**

    SELECT
      COUNT(DISTINCT order_id) AS orders_made
    FROM
      pizza_runner.customer_orders;

| orders_made |
| ----------- |
| 10          |

---
**Query #22**

    SELECT
      COUNT(DISTINCT co.order_id) AS successful_orders
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.runner_orders ro ON ro.order_id = co.order_id
    WHERE
      cancellation IS NULL;

| successful_orders |
| ----------------- |
| 8                 |

---
**Query #23**

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

| pizza_id | total_orders |
| -------- | ------------ |
| 1        | 9            |
| 2        | 3            |

---
**Query #24**

    SELECT
      pn.pizza_name,
      COUNT(co.pizza_id) AS total_orders
    FROM
      pizza_runner.customer_orders co
    JOIN
      pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
    GROUP BY
      pn.pizza_name;

| pizza_name | total_orders |
| ---------- | ------------ |
| Meatlovers | 10           |
| Vegetarian | 4            |

---
**Query #25**

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

| qty_pizzas |
| ---------- |
| 3          |

---
**Query #26**

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

| customer_id | changes     | qty_pizzas |
| ----------- | ----------- | ---------- |
| 101         | Not Changed | 2          |
| 102         | Not Changed | 3          |
| 103         | Changed     | 3          |
| 104         | Changed     | 2          |
| 104         | Not Changed | 1          |
| 105         | Changed     | 1          |

---
**Query #27**

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

| changed_pizza_delivered |
| ----------------------- |
| 1                       |

---
**Query #28**

    SELECT
      EXTRACT(HOUR FROM order_time) AS hour_of_day,
      COUNT(pizza_id) AS qty_pizzas
    FROM
      pizza_runner.customer_orders
    GROUP BY
      hour_of_day
    ORDER BY
      hour_of_day;

| hour_of_day | qty_pizzas |
| ----------- | ---------- |
| 11          | 1          |
| 13          | 3          |
| 18          | 3          |
| 19          | 1          |
| 21          | 3          |
| 23          | 3          |

---
**Query #29**

    SELECT
      EXTRACT(DOW FROM order_time) AS week_day,
      COUNT(pizza_id) AS qty_pizzas
    FROM
      pizza_runner.customer_orders
    GROUP BY
      week_day
    ORDER BY
      week_day;

| week_day | qty_pizzas |
| -------- | ---------- |
| 3        | 5          |
| 4        | 3          |
| 5        | 1          |
| 6        | 5          |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
