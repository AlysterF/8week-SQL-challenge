## B. Data Analysis Questions 📊🔍


**Query #1**

How many customers has Foodie-Fi ever had?

````sql
    SELECT COUNT(DISTINCT customer_id) AS number_of_customers
    FROM foodie_fi.subscriptions;
````

***Output***

| number_of_customers |
| ------------------- |
| 1000                |

---
**Query #2**

What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

````sql
    SELECT
    	DATE_TRUNC('month', start_date) AS beginning_month,
    	COUNT(plan_id) AS trial_plans
    FROM
    	foodie_fi.subscriptions
    GROUP BY beginning_month, plan_id
    HAVING plan_id = 0
    ORDER BY beginning_month;
````

***Output***

| beginning_month          | trial_plans |
| ------------------------ | ----------- |
| 2020-01-01T00:00:00.000Z | 88          |
| 2020-02-01T00:00:00.000Z | 68          |
| 2020-03-01T00:00:00.000Z | 94          |
| 2020-04-01T00:00:00.000Z | 81          |
| 2020-05-01T00:00:00.000Z | 88          |
| 2020-06-01T00:00:00.000Z | 79          |
| 2020-07-01T00:00:00.000Z | 89          |
| 2020-08-01T00:00:00.000Z | 88          |
| 2020-09-01T00:00:00.000Z | 87          |
| 2020-10-01T00:00:00.000Z | 79          |
| 2020-11-01T00:00:00.000Z | 75          |
| 2020-12-01T00:00:00.000Z | 84          |

---
**Query #3**

What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

````sql
    SELECT p.plan_name, COUNT(s.plan_id) AS total_plans
    FROM foodie_fi.plans p
    JOIN foodie_fi.subscriptions s ON s.plan_id = p.plan_id
    WHERE EXTRACT(YEAR FROM s.start_date)>2020
    GROUP BY p.plan_name
    ORDER BY total_plans DESC;
````

***Output***

| plan_name     | total_plans |
| ------------- | ----------- |
| churn         | 71          |
| pro annual    | 63          |
| pro monthly   | 60          |
| basic monthly | 8           |

---
**Query #4**

What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

````sql
    SELECT
    	COUNT(DISTINCT customer_id) AS customers_churned,
        ROUND((COUNT(DISTINCT customer_id)::DECIMAL/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100, 1) AS perc_of_total
    FROM foodie_fi.subscriptions
    WHERE plan_id = 4;
````

***Output***

| customers_churned | perc_of_total |
| ----------------- | ------------- |
| 307               | 30.7          |

---
**Query #5**

How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

````sql
    SELECT
    	COUNT(DISTINCT customer_id) AS customer_churned,
        CEIL((COUNT(DISTINCT customer_id)::DECIMAL/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100) AS ceil_perc_of_total
    FROM
    	foodie_fi.subscriptions s
    WHERE
    	plan_id = 4 AND
        start_date = (SELECT start_date FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id AND plan_id = 0) + 7;
````

***Output***

| customer_churned | ceil_perc_of_total |
| ---------------- | ------------------ |
| 92               | 10                 |

---
**Query #6**

What is the number and percentage of customer plans after their initial free trial?

````sql
    SELECT
    	COUNT(plan_id) AS qty_plans,
        ROUND((COUNT(plan_id)::DECIMAL/(SELECT COUNT(plan_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100, 2) AS perc_of_total
    FROM
    	foodie_fi.subscriptions s
    WHERE
    	plan_id NOT IN (0,4) AND
        start_date >= (SELECT start_date FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id AND plan_id = 0) + 7;
````

***Output***

| qty_plans | perc_of_total |
| --------- | ------------- |
| 1343      | 50.68         |

---
**Query #7**

What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

````sql
    SELECT
    	s.start_date AS analyzed_date,
        p.plan_name,
        COUNT(DISTINCT s.customer_id),
        ROUND((COUNT(DISTINCT s.customer_id)::DECIMAL/(SELECT COUNT(DISTINCT s.customer_id) FROM foodie_fi.subscriptions WHERE start_date = '2020-12-31')::DECIMAL) * 100, 2) AS perc_of_total
    FROM
    	foodie_fi.subscriptions s
    JOIN
    	foodie_fi.plans p ON p.plan_id = s.plan_id
    WHERE
    	s.start_date = '2020-12-31'
    GROUP BY
    	analyzed_date, plan_name
    ORDER BY
    	plan_name;
````

***Output***

| analyzed_date            | plan_name | count | perc_of_total |
| ------------------------ | --------- | ----- | ------------- |
| 2020-12-31T00:00:00.000Z | churn     | 1     | 100.00        |

---
**Query #8**

How many customers have upgraded to an annual plan in 2020?

````sql
    SELECT
    	COUNT(DISTINCT customer_id) AS total_customers
    FROM
    	foodie_fi.subscriptions
    WHERE
    	plan_id = 3;
````

***Output***

| total_customers |
| --------------- |
| 258             |

---
**Query #9**

How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

````sql
    WITH time_to_upgrade AS(
    	SELECT
      		s.customer_id,
      		s.plan_id,
      		(s.start_date-(SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id)) AS time_to_upgrade
    	FROM foodie_fi.subscriptions s
    	WHERE s.plan_id = 3
    )
    
    SELECT
    	AVG(time_to_upgrade)::INTEGER AS avg_time_to_pro_annual
    FROM
    	time_to_upgrade;
````

***Output***

| avg_time_to_pro_annual |
| ---------------------- |
| 105                    |

---
**Query #10**

Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

To solve this challenge, I had to check what was the maximum interval between the join date of a customer until the customer upgarde to an annual plan.
Through the query below, I was able to see that the value was 346 days. That's why I used 360 days as a the limit for the bucket in the solution query.


````sql
--query to find the maximum interval

WITH customer_time AS(
	SELECT
  		s.customer_id,
  		MAX(start_date) - (SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id) AS days_diff
  	FROM foodie_fi.subscriptions s
  	WHERE s.plan_id = 3
  	GROUP BY customer_id
)
SELECT MAX(days_diff) FROM customer_time;
````

For the solution query I had to use WIDTH_BUCKET function. That function breaks an interval of number into an specific number of parts.
In this solution, I've used this function to create 12 buckets between 0 and 360, and to determine in which bucket the date would be,
I selected the difference between the current date and the join date (start_date).

To make it more clear to you, when I break 0-360 into 12 parts, I got 12 buckets of 30 days each numbered from 1 to 12.
If the difference of the current date and the join date is 28, it goes to bucket 1. If it's 356, it goes to bucket 12.


Solution Query:

````sql
    WITH upgrade AS(
    	SELECT
      		s.customer_id,
      		s.plan_id,
      		(WIDTH_BUCKET((s.start_date-(SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id)),0,360,12) - 1) AS bucket
    	FROM foodie_fi.subscriptions s
    	WHERE s.plan_id = 3
    )
    
    SELECT
    	CASE
        	WHEN bucket = 0
            	THEN bucket * 30 || '-' || (bucket+1)*30 || ' days'
        	ELSE
            	(bucket * 30)+1 || '-' || (bucket+1)*30 || ' days'
    	END AS period,
        COUNT(DISTINCT customer_id) AS customers
    FROM
    	upgrade
    GROUP BY bucket, period
    ORDER BY bucket;
````

***Output***

| period       | customers |
| ------------ | --------- |
| 0-30 days    | 48        |
| 31-60 days   | 25        |
| 61-90 days   | 33        |
| 91-120 days  | 35        |
| 121-150 days | 43        |
| 151-180 days | 35        |
| 181-210 days | 27        |
| 211-240 days | 4         |
| 241-270 days | 5         |
| 271-300 days | 1         |
| 301-330 days | 1         |
| 331-360 days | 1         |

---
**Query #11**

How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

For this challenge I've used a CTE to keep only the 2020 records regarding plan 1 and 2.
Once I had this filtered database, I was able to count how many customers have downgrade from plan 2 to plan 1.
To make this happen it was quite simple, I only had to filter plan 1 data and check if the date regarding this plan was higher then the plan 2 for the same customer.
Once it would mean that the plan 1 was purchased after plan 2.

````sql
    WITH filtered_customers AS(
      SELECT
      	customer_id,
      	plan_id,
      	start_date
      FROM
      	foodie_fi.subscriptions
      WHERE
      	(plan_id = 1 OR plan_id = 2)
      	AND EXTRACT(YEAR FROM start_date) = 2020
    )
             
    SELECT
    	COUNT(f.customer_id) AS customers_downgraded
    FROM
    	filtered_customers f
    WHERE
    	f.plan_id = 1
    	AND f.start_date > (SELECT start_date FROM filtered_customers WHERE customer_id = f.customer_id AND plan_id = 2);
````

***Output***

| customers_downgraded |
| -------------------- |
| 0                    |

---

[View the original schema on DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16)
