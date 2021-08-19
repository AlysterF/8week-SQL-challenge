**Schema (PostgreSQL v13)**

    CREATE SCHEMA dannys_diner;
    SET search_path = dannys_diner;
    
    CREATE TABLE sales (
      "customer_id" VARCHAR(1),
      "order_date" DATE,
      "product_id" INTEGER
    );
    
    INSERT INTO sales
      ("customer_id", "order_date", "product_id")
    VALUES
      ('A', '2021-01-01', '1'),
      ('A', '2021-01-01', '2'),
      ('A', '2021-01-07', '2'),
      ('A', '2021-01-10', '3'),
      ('A', '2021-01-11', '3'),
      ('A', '2021-01-11', '3'),
      ('B', '2021-01-01', '2'),
      ('B', '2021-01-02', '2'),
      ('B', '2021-01-04', '1'),
      ('B', '2021-01-11', '1'),
      ('B', '2021-01-16', '3'),
      ('B', '2021-02-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-07', '3');
     
    
    CREATE TABLE menu (
      "product_id" INTEGER,
      "product_name" VARCHAR(5),
      "price" INTEGER
    );
    
    INSERT INTO menu
      ("product_id", "product_name", "price")
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');
      
    
    CREATE TABLE members (
      "customer_id" VARCHAR(1),
      "join_date" DATE
    );
    
    INSERT INTO members
      ("customer_id", "join_date")
    VALUES
      ('A', '2021-01-07'),
      ('B', '2021-01-09');

---

**Query #1**

    SELECT s.customer_id, SUM(m.price) AS total_spent
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON m.product_id = s.product_id
    GROUP BY s.customer_id
    ORDER BY total_spent DESC;

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---
**Query #2**

    SELECT customer_id, COUNT(DISTINCT order_date) AS visits
    FROM dannys_diner.sales
    GROUP BY customer_id
    ORDER BY visits DESC;

| customer_id | visits |
| ----------- | ------ |
| B           | 6      |
| A           | 4      |
| C           | 2      |

---
**Query #3**

    WITH ranked_sales AS(
      SELECT s.customer_id, s.order_date, mn.product_name, DENSE_RANK() OVER(
        PARTITION BY s.customer_id
        ORDER BY s.order_date
      ) AS rank
      FROM dannys_diner.sales s
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    )
    SELECT customer_id, product_name
    FROM ranked_sales
    WHERE rank = 1
    GROUP BY customer_id, product_name;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**Query #4**

    SELECT mn.product_name, COUNT(s.product_id) AS times_purchased
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    GROUP BY mn.product_name
    ORDER BY times_purchased DESC
    LIMIT 1;

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

---
**Query #5**

    WITH product_rank_cust AS(
      SELECT s.customer_id, mn.product_name, COUNT(s.product_id) AS purchases,
      DENSE_RANK() OVER(
        PARTITION BY s.customer_id
        ORDER BY COUNT(s.product_id) DESC
      ) AS rank
      FROM dannys_diner.sales s
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
      GROUP BY s.customer_id, mn.product_name
    )
    
    SELECT customer_id, product_name, purchases
    FROM product_rank_cust
    WHERE rank = 1
    ORDER BY customer_id;

| customer_id | product_name | purchases |
| ----------- | ------------ | --------- |
| A           | ramen        | 3         |
| B           | ramen        | 2         |
| B           | curry        | 2         |
| B           | sushi        | 2         |
| C           | ramen        | 3         |

---
**Query #6**

    WITH ranked_product_members AS(
      SELECT mb.customer_id, mn.product_name, s.order_date,
      DENSE_RANK() OVER(
        PARTITION BY mb.customer_id
        ORDER BY s.order_date
      ) AS rank
      FROM dannys_diner.members mb
      JOIN dannys_diner.sales s ON s.customer_id = mb.customer_id
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
      WHERE s.order_date >= mb.join_date
    )
    SELECT customer_id, product_name, order_date
    FROM ranked_product_members
    WHERE rank = 1;

| customer_id | product_name | order_date               |
| ----------- | ------------ | ------------------------ |
| A           | curry        | 2021-01-07T00:00:00.000Z |
| B           | sushi        | 2021-01-11T00:00:00.000Z |

---
**Query #7**

    WITH ranked_product_notmembers AS(
      SELECT mb.customer_id, mn.product_name, s.order_date,
      DENSE_RANK() OVER(
        PARTITION BY mb.customer_id
        ORDER BY s.order_date DESC
      ) AS rank
      FROM dannys_diner.members mb
      JOIN dannys_diner.sales s ON s.customer_id = mb.customer_id
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
      WHERE s.order_date < mb.join_date
    )
    SELECT customer_id, product_name, order_date
    FROM ranked_product_notmembers
    WHERE rank = 1;

| customer_id | product_name | order_date               |
| ----------- | ------------ | ------------------------ |
| A           | sushi        | 2021-01-01T00:00:00.000Z |
| A           | curry        | 2021-01-01T00:00:00.000Z |
| B           | sushi        | 2021-01-04T00:00:00.000Z |

---
**Query #8**

    WITH purchases_before_member AS(
      SELECT mb.customer_id, mn.product_name, mn.price
      FROM dannys_diner.members mb
      JOIN dannys_diner.sales s ON s.customer_id = mb.customer_id
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
      WHERE s.order_date < mb.join_date
    )
    SELECT customer_id, COUNT(product_name) AS total_items, SUM(price) AS total_price
    FROM purchases_before_member
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | total_items | total_price |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

---
**Query #9**

    WITH points_per_purchase AS(
      SELECT s.customer_id, mn.product_name, mn.price,
      CASE
      	WHEN mn.product_name = 'sushi' THEN 2
      	ELSE 1
      END AS multiplier,
      (mn.price * 10) AS points
      FROM dannys_diner.sales s
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    )
    SELECT customer_id, SUM((points * multiplier)) AS total_points
    FROM points_per_purchase
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---
**Query #10**

    WITH points_purch_member AS(
      SELECT s.customer_id, mn.product_name, mn.price, s.order_date,
      CASE
      	WHEN mn.product_name = 'sushi' THEN 2
      	WHEN s.customer_id IN (SELECT customer_id FROM dannys_diner.members) AND (s.order_date >= mb.join_date AND s.order_date < (mb.join_date+7)) THEN 2
      	ELSE 1
      END AS multiplier,
      (mn.price * 10) AS points
      FROM dannys_diner.sales s
      JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
      JOIN dannys_diner.members mb ON mb.customer_id = s.customer_id
    )
    SELECT customer_id, SUM((points * multiplier)) AS total_points
    FROM points_purch_member
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 940          |

---
**Query #11**

    SELECT s.customer_id, s.order_date, mn.product_name, mn.price,
    	CASE
    		WHEN s.order_date >= mb.join_date THEN 'Y'
    		ELSE 'N'
    	END AS member
    FROM dannys_diner.sales s
    LEFT JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    LEFT JOIN dannys_diner.members mb ON mb.customer_id = s.customer_id
    ORDER BY s.customer_id, s.order_date;

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |

---
**Query #12**

    WITH classified_db AS(
    	SELECT s.customer_id, s.order_date, mn.product_name, mn.price,
    	CASE
    		WHEN s.order_date >= mb.join_date THEN 'Y'
    		ELSE 'N'
    	END AS member
    	FROM dannys_diner.sales s
    	LEFT JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    	LEFT JOIN dannys_diner.members mb ON mb.customer_id = s.customer_id
    	ORDER BY s.customer_id, s.order_date
    )
    SELECT *,
    CASE
    	WHEN member = 'N' THEN null
    	ELSE RANK() OVER(
        	PARTITION BY customer_id, member
        	ORDER BY order_date
        )
    END AS ranking
    FROM classified_db;

| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/487)
