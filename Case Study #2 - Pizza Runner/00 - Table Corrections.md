````sql
--##############################
--corrections in customer_orders

--exclusions
UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE exclusions = '' OR  exclusions = 'null';

--extras
UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE extras = '' OR  extras = 'null';


--##############################
--corrections in runner_orders

--pickup_time
UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE pickup_time = '' or pickup_time = 'null';

ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP
USING pickup_time::TIMESTAMP;

--distance
UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE distance = '' or distance = 'null';

UPDATE pizza_runner.runner_orders
SET distance = REPLACE(distance, 'km', '')
WHERE distance LIKE '%km';

ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN distance TYPE DECIMAL
USING distance::decimal;

--duration
UPDATE pizza_runner.runner_orders
SET duration = NULL
WHERE duration = '' or duration = 'null';

UPDATE pizza_runner.runner_orders
SET duration = REPLACE(duration, 'mins', '')
WHERE duration LIKE '%mins';

UPDATE pizza_runner.runner_orders
SET duration = REPLACE(duration, 'minutes', '')
WHERE duration LIKE '%minutes';

UPDATE pizza_runner.runner_orders
SET duration = REPLACE(duration, 'minute', '')
WHERE duration LIKE '%minute';

ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN duration TYPE INTEGER
USING duration::integer;

--cancellation
UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE cancellation = '' or cancellation = 'null';

UPDATE pizza_runner.runner_orders
SET cancellation = REPLACE(cancellation, ' Cancellation', '')
WHERE cancellation LIKE '%Cancellation';


--##############################
--normalization of pizza_recipes

CREATE TEMP TABLE pizza_ingredients AS
  SELECT pr.pizza_id, regexp_split_to_table(pr.toppings, E',')::INTEGER AS topping_id
    FROM pizza_runner.pizza_recipes pr;
    

--add surrogate key in customer orders
CREATE TEMP TABLE cust_orders AS
  SELECT *
    FROM pizza_runner.customer_orders
    ORDER BY order_id;

ALTER TABLE cust_orders ADD COLUMN id SERIAL PRIMARY KEY;


--##############################
--normalization of exclusions e extras

CREATE TEMP TABLE exclusions AS
  SELECT id, order_id, regexp_split_to_table(exclusions, E',')::INTEGER AS exclusion_id
    FROM cust_orders;
    
CREATE TEMP TABLE extras AS
  SELECT id, order_id, regexp_split_to_table(extras, E',')::INTEGER AS extra_id
    FROM cust_orders;
    
````
