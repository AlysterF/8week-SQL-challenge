[Back to ReadMe](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/README.md)

### Schema creation


**Schema (PostgreSQL v13)**
````sql
--Schema created by Danny Ma from Data with Danny
--PostgreSQL v13

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
````
---

### Solutions

````sql
--Scripts created by Alyster Fernandes
--Aug 19, 2021
--PostgreSQL v13
````

**Query #1**

What is the total amount each customer spent at the restaurant?

````sql

/* select the customer id and aggregate the price using sum 
it's important to remember that if you are showing any other columns different
from the aggregation you have to group the agg column using the others as reference.*/

    SELECT s.customer_id, SUM(m.price) AS total_spent
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON m.product_id = s.product_id
    GROUP BY s.customer_id
    ORDER BY total_spent DESC;
````

***Output***

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---
**Query #2**

How many days has each customer visited the restaurant?

````sql
/*here I used count distinct because some customer order multiple times in the same day,
so we have duplicated dates that should be counted as one.*/

    SELECT customer_id, COUNT(DISTINCT order_date) AS visits
    FROM dannys_diner.sales
    GROUP BY customer_id
    ORDER BY visits DESC;
````

***Output***

| customer_id | visits |
| ----------- | ------ |
| B           | 6      |
| A           | 4      |
| C           | 2      |

---
**Query #3**

What was the first item from the menu purchased by each customer?

````sql
/*I used CTE here to determine a rank for the orders based on the order date.
The use of CTE is to facilited the understanding of the query, and it's my preference not
to use subqueries, I really think CTE is more simple to understand.

Also I've used DENSE_RANK function, because once we do not have time together with date,
I have to assume that everything ordered in the same day has to be ranked the same.
The dense_rank function does exactly that.*/

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
````

***Output***

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

The customer A ordered two items in the first visit: curry and sushi.
Customer B ordered curry and customer C ordered ramem.

---
**Query #4**

What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
    SELECT mn.product_name, COUNT(s.product_id) AS times_purchased
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    GROUP BY mn.product_name
    ORDER BY times_purchased DESC
    LIMIT 1;
````

***Output***

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

People really like Danny's Diner ramem!

---
**Query #5**

Which item was the most popular for each customer?

````sql
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
````

***Output***

| customer_id | product_name | purchases |
| ----------- | ------------ | --------- |
| A           | ramen        | 3         |
| B           | ramen        | 2         |
| B           | curry        | 2         |
| B           | sushi        | 2         |
| C           | ramen        | 3         |

Well, it looks like the customer B make really balanced choices.

---
**Query #6**

Which item was purchased first by the customer after they became a member?

````sql
/*This code is tricky, sometimes people think why the customer C doesn't appear
if I'm joining everything? Well, if you use JOIN clause you are inner joining
everything, and inner join only show the results where the indicated key comparision matches*/

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
````

***Output***

| customer_id | product_name | order_date               |
| ----------- | ------------ | ------------------------ |
| A           | curry        | 2021-01-07T00:00:00.000Z |
| B           | sushi        | 2021-01-11T00:00:00.000Z |

---
**Query #7**

Which item was purchased just before the customer became a member?

````sql
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
````

***Output***

| customer_id | product_name | order_date               |
| ----------- | ------------ | ------------------------ |
| A           | sushi        | 2021-01-01T00:00:00.000Z |
| A           | curry        | 2021-01-01T00:00:00.000Z |
| B           | sushi        | 2021-01-04T00:00:00.000Z |

---
**Query #8**

What is the total items and amount spent for each member before they became a member?

````sql
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
````

***Output***

| customer_id | total_items | total_price |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

---
**Query #9**

If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
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
````

***Output***

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---
**Query #10**

In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
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
````

***Output***

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 940          |

---

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. The reference models are in the [Case Study #1 page](https://8weeksqlchallenge.com/case-study-1/).


**Query #11**

Create a table with customer id, order date, product name, price and insert a columns to inform if in the respective date the customer was a member or not. 

````sql
    SELECT s.customer_id, s.order_date, mn.product_name, mn.price,
    	CASE
    		WHEN s.order_date >= mb.join_date THEN 'Y'
    		ELSE 'N'
    	END AS member
    FROM dannys_diner.sales s
    LEFT JOIN dannys_diner.menu mn ON mn.product_id = s.product_id
    LEFT JOIN dannys_diner.members mb ON mb.customer_id = s.customer_id
    ORDER BY s.customer_id, s.order_date;
````

***Output***

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

Create a table similar to the last one, but insert a columns to rank the order by date, but only consider the purchases that occured when a customer was a member.

````sql
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
````

***Output***

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

[View the schema and questions (without solutions) on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/487)

[Back to ReadMe](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/README.md)
