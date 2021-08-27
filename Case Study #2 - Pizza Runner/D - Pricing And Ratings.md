## D. Pricing and Ratings 💰 ⭐⭐⭐⭐⭐

---
**Query #01**

If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

````sql
    WITH pricing AS(
      SELECT co.id, pn.pizza_name,
        CASE
          WHEN pn.pizza_name = 'Meatlovers' THEN 12
          ELSE 10
        END AS pizza_price
      FROM cust_orders co
      JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
      JOIN pizza_runner.runner_orders ro ON ro.order_id = co.order_id
      WHERE ro.cancellation IS NULL
      ORDER BY id
    )
    
    SELECT SUM(pizza_price) FROM pricing;
````

***Output***

| sum |
| --- |
| 138 |


---
**Query #02**

What if there was an additional $1 charge for any pizza extras?

    Add cheese is $1 extra ($2 for extra cheese)


````sql
    WITH first_pricing AS(
      SELECT co.id, pn.pizza_name,
        CASE pn.pizza_name
          WHEN 'Meatlovers' THEN 12
          ELSE 10
        END AS pizza_price
      FROM cust_orders co
      JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
      JOIN pizza_runner.runner_orders ro ON ro.order_id = co.order_id
      WHERE ro.cancellation IS NULL
      ORDER BY id
    ),
    
    second_pricing AS(
      SELECT fp.*, pt.topping_name,
        CASE 
          WHEN pt.topping_name = 'Cheese' THEN 2
          WHEN pt.topping_name IS NOT NULL THEN 1
          ELSE 0
        END AS extra_charge
      FROM first_pricing fp
      LEFT JOIN extras pe ON pe.id = fp.id
      LEFT JOIN pizza_runner.pizza_toppings pt ON pt.topping_id = pe.extra_id
      ORDER BY id
    ),
    
    third_pricing AS(
      SELECT id, pizza_name, MAX(pizza_price) AS pizza_price, SUM(extra_charge) AS extra_charges
      FROM second_pricing
      GROUP BY id, pizza_name
      ORDER BY id
    )
    
    SELECT (SUM(pizza_price) + SUM(extra_charges)) AS total_earned
    FROM third_pricing;
````

***Output***

| total_earned |
| ------------ |
| 143          |


---
**Query #03**

The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
    DROP TABLE IF EXISTS customer_ratings;

    CREATE TABLE customer_ratings (
      "order_id" INTEGER,
      "rating" INTEGER,
      "additional_comments" VARCHAR(150),
      "rating_time" TIMESTAMP
    );
````

No output for this one, it's only the creation of a new table. :)

The data inserted into ratings table:

````sql
    INSERT INTO customer_ratings
      ("order_id", "rating", "additional_comments", "rating_time")
    VALUES
      ('1', '4', 'A little late but very polite runner!', '2020-01-01 18:57:54'),
      ('2', '5', NULL, '2020-01-01 22:01:32'),
      ('3', '5','Excellent!', '2020-01-04 01:11:09'),
      ('4', '2', 'Late and didnt even told me good afternoon', '2020-01-04 14:37:14'),
      ('5', '5', NULL, '2020-01-08 21:59:44'),
      ('7', '5', 'Please promote this guy!', '2020-01-08 21:58:22'),
      ('8', '5', NULL, '2020-01-12 13:20:01'),
      ('10', '5', 'Perfect!', '2020-01-11 21:22:57');
````

---
**Query #04**

Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

    - customer_id
    - order_id
    - runner_id
    - rating
    - order_time
    - pickup_time
    - Time between order and pickup
    - Delivery duration
    - Average speed
    - Total number of pizzas


````sql
    SELECT
      co.customer_id,
      ro.order_id,
      ro.runner_id,
      cr.rating,
      co.order_time,
      ro.pickup_time,
      DATE_PART('hour', ro.pickup_time - co.order_time) * 60
      + DATE_PART('minute', ro.pickup_time - co.order_time) AS time_to_pickup,
      ro.duration,
      ROUND(CAST(ro.distance/ro.duration*60 AS DECIMAL), 2) AS avg_speed_kmh,
      COUNT(co.order_id) AS total_pizzas
    FROM pizza_runner.runner_orders ro
    JOIN cust_orders co ON co.order_id = ro.order_id
    JOIN customer_ratings cr ON cr.order_id = ro.order_id
    WHERE ro.cancellation IS NULL
    GROUP BY
      co.customer_id,
      ro.order_id,
      ro.runner_id,
      cr.rating,
      co.order_time,
      ro.pickup_time,
      time_to_pickup,
      ro.duration,
      avg_speed_kmh
    ORDER BY co.customer_id, ro.order_id;
````

***Output***

| customer_id | order_id | runner_id | rating | order_time               | pickup_time              | time_to_pickup | duration | avg_speed_kmh | total_pizzas |
| ----------- | -------- | --------- | ------ | ------------------------ | ------------------------ | -------------- | -------- | ------------- | ------------ |
| 101         | 1        | 1         | 4      | 2020-01-01T18:05:02.000Z | 2020-01-01T18:15:34.000Z | 10             | 32       | 37.50         | 1            |
| 101         | 2        | 1         | 5      | 2020-01-01T19:00:52.000Z | 2020-01-01T19:10:54.000Z | 10             | 27       | 44.44         | 1            |
| 102         | 3        | 1         | 5      | 2020-01-02T23:51:23.000Z | 2020-01-03T00:12:37.000Z | 21             | 20       | 40.20         | 2            |
| 102         | 8        | 2         | 5      | 2020-01-09T23:54:33.000Z | 2020-01-10T00:15:02.000Z | 20             | 15       | 93.60         | 1            |
| 103         | 4        | 2         | 2      | 2020-01-04T13:23:46.000Z | 2020-01-04T13:53:03.000Z | 29             | 40       | 35.10         | 3            |
| 104         | 5        | 3         | 5      | 2020-01-08T21:00:29.000Z | 2020-01-08T21:10:57.000Z | 10             | 15       | 40.00         | 1            |
| 104         | 10       | 1         | 5      | 2020-01-11T18:34:49.000Z | 2020-01-11T18:50:20.000Z | 15             | 10       | 60.00         | 2            |
| 105         | 7        | 2         | 5      | 2020-01-08T21:20:29.000Z | 2020-01-08T21:30:45.000Z | 10             | 25       | 60.00         | 1            |


---
**Query #05**

If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

````sql
    WITH first_delivery_fee AS(
      SELECT ro.order_id, ro.distance,
      (ro.distance*0.3) AS runner_fee
      FROM pizza_runner.runner_orders ro
      WHERE ro.cancellation IS NULL
      ORDER BY ro.order_id
    ),
    
    second_delivery_fee AS(
      SELECT fd.*, pn.pizza_name,
        CASE pn.pizza_name
          WHEN 'Meatlovers' THEN 12
          ELSE 10
        END AS pizza_price
      FROM first_delivery_fee fd
      JOIN cust_orders co ON co.order_id = fd.order_id
      JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
      ORDER BY fd.order_id
    ),
    
    third_delivery_fee AS(
      SELECT
      order_id,
      MAX(runner_fee) AS runner_fee,
      SUM(pizza_price) AS total_price
      FROM second_delivery_fee
      GROUP BY order_id
      ORDER BY order_id
    )
    
    SELECT
      SUM(total_price) AS total_revenue,
      SUM(runner_fee) AS total_costs,
      (SUM(total_price) - SUM(runner_fee)) AS total_profit
    FROM third_delivery_fee;
````

***Output***

| total_revenue | total_costs | total_profit |
| ------------- | ----------- | ------------ |
| 138           | 43.56       | 94.44        |

Still a good profit considering only the costs of runners, right? :)

---

[View the original schema on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
