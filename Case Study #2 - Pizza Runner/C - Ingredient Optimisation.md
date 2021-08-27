## C - Ingredient Optimisation 🧀🥓

---
**Query #01**

What are the standard ingredients for each pizza?

````sql
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
````

***Output***

| pizza_name | topping_name |
| ---------- | ------------ |
| Meatlovers | BBQ Sauce    |
| Meatlovers | Bacon        |
| Meatlovers | Beef         |
| Meatlovers | Cheese       |
| Meatlovers | Chicken      |
| Meatlovers | Mushrooms    |
| Meatlovers | Pepperoni    |
| Meatlovers | Salami       |
| Vegetarian | Cheese       |
| Vegetarian | Mushrooms    |
| Vegetarian | Onions       |
| Vegetarian | Peppers      |
| Vegetarian | Tomato Sauce |
| Vegetarian | Tomatoes     |


---
**Query #02**

What was the most commonly added extra?

````sql
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
````

***Output***

| topping_name | total_added |
| ------------ | ----------- |
| Bacon        | 4           |


---
**Query #03**

What was the most common exclusion?

````sql
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
````

***Output***

| topping_name | total_excluded |
| ------------ | -------------- |
| Cheese       | 4              |

---
**Query #04**

Generate an order item for each record in the customers_orders table in the format of one of the following:

    Meat Lovers
    Meat Lovers - Exclude Beef
    Meat Lovers - Extra Bacon
    Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

This was one of the hardest queries I had to write. I'm not sure if the currenct query is in its higher efficiency, but I was just glad I was able to get the answer!
I'm really open to comments, ok? Feel free to send me a message to comment your opinion about this query.

````sql
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
````

***Output***

| id  | full_order                                                      |
| --- | --------------------------------------------------------------- |
| 1   | Meatlovers                                                      |
| 2   | Meatlovers                                                      |
| 3   | Meatlovers                                                      |
| 4   | Vegetarian                                                      |
| 5   | Meatlovers - Exclude Cheese                                     |
| 6   | Meatlovers - Exclude Cheese                                     |
| 7   | Vegetarian - Exclude Cheese                                     |
| 8   | Meatlovers - Extra Bacon                                        |
| 9   | Vegetarian                                                      |
| 10  | Vegetarian - Extra Bacon                                        |
| 11  | Meatlovers                                                      |
| 12  | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 13  | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
| 14  | Meatlovers                                                      |


---
**Query #05**

Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

    For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

This one was easier than the last one, specially because I didn't have to show which ingredient was excluded, I just deleted them from the list of ingredients.

````sql
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
````

***Output***

| id  | order_id | order_detail                                                                        |
| --- | -------- | ----------------------------------------------------------------------------------- |
| 1   | 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2   | 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3   | 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 4   | 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 5   | 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 6   | 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 7   | 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 8   | 5        | Meatlovers: BBQ Sauce, 2xBacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 9   | 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 10  | 7        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 11  | 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 12  | 9        | Meatlovers: BBQ Sauce, 2xBacon, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
| 13  | 10       | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |
| 14  | 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |


---
**Query #06**

What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

````sql
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
````

| ingredient   | total_used |
| ------------ | ---------- |
| Mushrooms    | 13         |
| Bacon        | 13         |
| Chicken      | 11         |
| Cheese       | 11         |
| Pepperoni    | 10         |
| Salami       | 10         |
| Beef         | 10         |
| BBQ Sauce    | 9          |
| Tomatoes     | 4          |
| Onions       | 4          |
| Peppers      | 4          |
| Tomato Sauce | 4          |


Of course cheese was one of the top 5. Cheese is life!

---

[View the original schema on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
