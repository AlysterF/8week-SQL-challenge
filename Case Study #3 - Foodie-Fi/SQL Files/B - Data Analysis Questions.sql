-- Surrogate key to subscriptions

ALTER TABLE foodie_fi.subscriptions ADD COLUMN id SERIAL PRIMARY KEY;


--Queries
--B. Data Analysis Questions

--1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM foodie_fi.subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
	DATE_TRUNC('month', start_date) AS beginning_month,
	COUNT(plan_id) AS trial_plans
FROM
	foodie_fi.subscriptions
GROUP BY beginning_month, plan_id
HAVING plan_id = 0
ORDER BY beginning_month;


--3; What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT p.plan_name, COUNT(s.plan_id) AS total_plans
FROM foodie_fi.plans p
JOIN foodie_fi.subscriptions s ON s.plan_id = p.plan_id
WHERE EXTRACT(YEAR FROM s.start_date)>2020
GROUP BY p.plan_name
ORDER BY total_plans DESC;


--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	COUNT(DISTINCT customer_id) AS customers_churned,
    ROUND((COUNT(DISTINCT customer_id)::DECIMAL/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100, 1) AS perc_of_total
FROM foodie_fi.subscriptions
WHERE plan_id = 4;
    

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

SELECT
	COUNT(DISTINCT customer_id) AS customer_churned,
    CEIL((COUNT(DISTINCT customer_id)::DECIMAL/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100) AS ceil_perc_of_total
FROM
	foodie_fi.subscriptions s
WHERE
	plan_id = 4 AND
    start_date = (SELECT start_date FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id AND plan_id = 0) + 7;


--6. What is the number and percentage of customer plans after their initial free trial?

SELECT
	COUNT(plan_id) AS qty_plans,
    ROUND((COUNT(plan_id)::DECIMAL/(SELECT COUNT(plan_id) FROM foodie_fi.subscriptions)::DECIMAL) * 100, 2) AS perc_of_total
FROM
	foodie_fi.subscriptions s
WHERE
	plan_id NOT IN (0,4) AND
    start_date >= (SELECT start_date FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id AND plan_id = 0) + 7;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

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

--8. How many customers have upgraded to an annual plan in 2020?

SELECT
	COUNT(DISTINCT customer_id) AS total_customers
FROM
	foodie_fi.subscriptions
WHERE
	plan_id = 3;

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

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

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


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
  
--através da query abaixo, verifiquei que o intervalo máximo entre pessoas que contratam o plano anual foi de 346 dias. Por isso, utilizei 360 dias como limite na query final.
/*WITH customer_time AS(
	SELECT
  		s.customer_id,
  		MAX(start_date) - (SELECT MIN(start_date) FROM foodie_fi.subscriptions WHERE customer_id = s.customer_id) AS days_diff
  	FROM foodie_fi.subscriptions s
  	WHERE s.plan_id = 3
  	GROUP BY customer_id
)
SELECT MAX(days_diff) FROM customer_time;*/

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

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
