/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  s.customer_id,
  SUM(m.price) AS total_spent
FROM
  dannys_diner.sales s
JOIN
  dannys_diner.menu m ON m.product_id = s.product_id
GROUP BY
  s.customer_id
ORDER BY
  total_spent DESC;

-- 2. How many days has each customer visited the restaurant?
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS visits
FROM
  dannys_diner.sales
GROUP BY
  customer_id
ORDER BY
  visits DESC;

-- 3. What was the first item from the menu purchased by each customer?

WITH ranked_sales AS(
  SELECT
    s.customer_id,
    s.order_date,
    mn.product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM
    dannys_diner.sales s
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
)
SELECT
  customer_id,
  product_name
FROM
  ranked_sales
WHERE
  rank = 1
GROUP BY
  customer_id,
  product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  mn.product_name,
  COUNT(s.product_id) AS times_purchased
FROM
  dannys_diner.sales s
JOIN
  dannys_diner.menu mn ON mn.product_id = s.product_id
GROUP BY
  mn.product_name
ORDER BY
  times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH product_rank_cust AS(
  SELECT
    s.customer_id,
    mn.product_name,
    COUNT(s.product_id) AS purchases,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank
  FROM
    dannys_diner.sales s
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
  GROUP BY
    s.customer_id,
    mn.product_name
)
SELECT
  customer_id,
  product_name,
  purchases
FROM
  product_rank_cust
WHERE
  rank = 1
ORDER BY
  customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
WITH ranked_product_members AS(
  SELECT
    mb.customer_id,
    mn.product_name,
    s.order_date,
    DENSE_RANK() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date) AS rank
  FROM
    dannys_diner.members mb
  JOIN
    dannys_diner.sales s ON s.customer_id = mb.customer_id
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
  WHERE
    s.order_date >= mb.join_date
)
SELECT
  customer_id,
  product_name,
  order_date
FROM
  ranked_product_members
WHERE
  rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH ranked_product_notmembers AS(
  SELECT
    mb.customer_id,
    mn.product_name,
    s.order_date,
    DENSE_RANK() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date DESC) AS rank
  FROM
    dannys_diner.members mb
  JOIN
    dannys_diner.sales s ON s.customer_id = mb.customer_id
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
  WHERE
    s.order_date < mb.join_date
)
SELECT
  customer_id,
  product_name,
  order_date
FROM
  ranked_product_notmembers
WHERE
  rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH purchases_before_member AS(
  SELECT
    mb.customer_id,
    mn.product_name,
    mn.price
  FROM
    dannys_diner.members mb
  JOIN
    dannys_diner.sales s ON s.customer_id = mb.customer_id
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
  WHERE
    s.order_date < mb.join_date
)
SELECT
  customer_id,
  COUNT(product_name) AS total_items,
  SUM(price) AS total_price
FROM
  purchases_before_member
GROUP BY
  customer_id
ORDER BY
  customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_per_purchase AS(
  SELECT
    s.customer_id,
    mn.product_name,
    mn.price,
    CASE
  	 WHEN mn.product_name = 'sushi' THEN 2
  	 ELSE 1
    END AS multiplier,
    (mn.price * 10) AS points
  FROM
    dannys_diner.sales s
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
)
SELECT
  customer_id,
  SUM((points * multiplier)) AS total_points
FROM
  points_per_purchase
GROUP BY
  customer_id
ORDER BY
  customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH points_purch_member AS(
  SELECT
    s.customer_id,
    mn.product_name,
    mn.price,
    s.order_date,
    CASE
  	 WHEN mn.product_name = 'sushi' THEN 2
  	 WHEN s.customer_id IN (SELECT customer_id FROM dannys_diner.members) AND (s.order_date >= mb.join_date AND s.order_date < (mb.join_date+7)) THEN 2
  	 ELSE 1
    END AS multiplier,
    (mn.price * 10) AS points
  FROM
    dannys_diner.sales s
  JOIN
    dannys_diner.menu mn ON mn.product_id = s.product_id
  JOIN
    dannys_diner.members mb ON mb.customer_id = s.customer_id
)
SELECT
  customer_id,
  SUM((points * multiplier)) AS total_points
FROM
  points_purch_member
GROUP BY
  customer_id
ORDER BY
  customer_id;