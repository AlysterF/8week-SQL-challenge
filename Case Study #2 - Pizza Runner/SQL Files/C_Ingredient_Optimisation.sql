--C. Ingredient Optimisation

--What are the standard ingredients for each pizza?
SELECT
  pn.pizza_name,
  pt.topping_name
FROM
  pizza_runner.pizza_names pn
JOIN
  pizza_ingredients pi ON pi.pizza_id = pn.pizza_id
JOIN
  pizza_runner.pizza_toppings pt ON pt.topping_id = pi.topping_id
ORDER BY
  pn.pizza_name,
  pt.topping_name;

--What was the most commonly added extra?
SELECT
  pt.topping_name,
  COUNT(pe.extra_id) AS total_added
FROM
  pizza_runner.pizza_toppings pt
JOIN
  extras pe ON pe.extra_id = pt.topping_id
GROUP BY
  pt.topping_name
ORDER BY
  total_added DESC
LIMIT 1;

--What was the most common exclusion?
SELECT
  pt.topping_name,
  COUNT(pe.exclusion_id) AS total_excluded
FROM
  pizza_runner.pizza_toppings pt
JOIN
  exclusions pe ON pe.exclusion_id = pt.topping_id
GROUP BY
  pt.topping_name
ORDER BY
  total_excluded DESC
LIMIT 1;

--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH exc_order_details AS(
  SELECT
    co.id,
    pn.pizza_id,
    pn.pizza_name,
    (
      SELECT
        topping_name
      FROM
        pizza_runner.pizza_toppings
      WHERE
        topping_id = pexc.exclusion_id
    ) AS exclusion_item
  FROM
    cust_orders co
  LEFT JOIN
    pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
  LEFT JOIN
    exclusions pexc ON pexc.id = co.id
  ORDER BY id
),

group_exclusion AS(
  SELECT
    id,
    pizza_id,
    pizza_name,
    STRING_AGG(exclusion_item, ', ' ORDER BY exclusion_item) excluded
  FROM
    exc_order_details
  GROUP BY
    id,
    pizza_id,
    pizza_name
),

ext_order_details AS(
  SELECT
    ge.id,
    ge.pizza_name,
    ge.excluded,
    (
      SELECT
        topping_name
      FROM
        pizza_runner.pizza_toppings
      WHERE
        topping_id = pe.extra_id
    ) AS extra_item
  FROM
    group_exclusion ge
  LEFT JOIN
    extras pe ON pe.id = ge.id  
  ORDER BY id
),

group_extra AS(
  SELECT
    id,
    pizza_name,
    excluded,
    STRING_AGG(extra_item, ', ' ORDER BY extra_item) extra
  FROM
    ext_order_details
  GROUP BY
    id,
    pizza_name,
    excluded
)

SELECT
  id, 
  CASE
    WHEN excluded IS NOT NULL AND extra IS NOT NULL
        THEN CONCAT(pizza_name, ' - Exclude ', excluded, ' - Extra ', extra)
      WHEN excluded IS NOT NULL AND extra IS NULL
        THEN CONCAT(pizza_name, ' - Exclude ', excluded)
      WHEN excluded IS NULL AND extra IS NOT NULL
        THEN CONCAT(pizza_name, ' - Extra ', extra)
      ELSE
        pizza_name
  END AS full_order
FROM group_extra;

--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH pizza_details AS(
  SELECT
    co.id,
    co.order_id,
    co.pizza_id,
    pn.pizza_name,
    pt.topping_name,
    CASE
      WHEN pt.topping_id IN (SELECT extra_id FROM extras WHERE id = co.id) THEN '2x'
      ELSE NULL
    END AS double_option
  FROM
    cust_orders co
  JOIN
    pizza_ingredients pi ON pi.pizza_id = co.pizza_id
  JOIN
    pizza_runner.pizza_names pn ON pn.pizza_id = pi.pizza_id
  JOIN
    pizza_runner.pizza_toppings pt ON pt.topping_id = pi.topping_id
  WHERE
    pt.topping_id NOT IN (SELECT exclusion_id FROM exclusions WHERE id = co.id)
  ORDER BY
    co.id,
    pt.topping_name
)

SELECT
  id,
  order_id,
  CONCAT(
    pizza_name,
    ': ',
    STRING_AGG(
      CONCAT(
        double_option,
        topping_name
      ),
      ', '
    )
  ) AS order_detail
FROM
  pizza_details
GROUP BY
  id,
  order_id,
  pizza_id,
  pizza_name
ORDER BY id;

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
                                       
WITH ingredient_count AS(
  SELECT
    co.id,
    co.order_id,
    co.pizza_id,
    pn.pizza_name,
    pt.topping_name,
    CASE
      WHEN
        pt.topping_id IN (SELECT extra_id FROM extras WHERE id = co.id)
      THEN
        '2'
      ELSE 1
    END AS ingredient_qty
  FROM
    cust_orders co
  JOIN
    pizza_ingredients pi ON pi.pizza_id = co.pizza_id
  JOIN
    pizza_runner.pizza_names pn ON pn.pizza_id = pi.pizza_id
  JOIN
    pizza_runner.pizza_toppings pt ON pt.topping_id = pi.topping_id
  WHERE
    pt.topping_id NOT IN (SELECT exclusion_id FROM exclusions WHERE id = co.id)
  ORDER BY
    co.id, pt.topping_name
)

SELECT
  topping_name AS ingredient,
  SUM(ingredient_qty) AS total_used
FROM
  ingredient_count
GROUP BY
  ingredient
ORDER BY
  total_used DESC;