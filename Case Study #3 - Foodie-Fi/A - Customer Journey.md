## A. Customer Journey 👥

To answer this question, I was based off the 8 sample customers provided in the sample from the subscriptions table, the challenge was to write a brief description about each customer’s onboarding journey.

Customers that were in the sample: (1,2,11,13,15,16,18,19)

````sql
SELECT s.customer_id, p.plan_name, p.price, s.start_date
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p ON p.plan_id = s.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19)
ORDER BY s.customer_id, s.start_date;
````

#### Customer 1

Started on trial on Aug 1st, 2020, and after the 7 days of trial downgraded it to basic monthly.

#### Customer 2

Started on trial on Sep 20th, 2020, and after the 7 days of trial upgraded to pro annual.

#### Customer 11

Started on trial on Nov 19th, 2020, and after the 7 days of trial cancelled the plan (so sad! Foodie-fi is a great platform, come back my friend!)

#### Customer 13

Started on trial on Dec 15th, 2020, and after the 7 days of trial downgrade to basic monthly. In the next year, on Mar 29th, 2021 the customer plan was upgraded to pro monthly.

#### Customer 15

Started on trial on Mar 17th, 2020, and after the 7 days of trial it automatically continued to pro monthly plan until he cancels it in Apr 29th, 2020.

#### Customer 16

Started on trial on May 31st, 2020, and after the 7 days of trial downgraded to basic monthly, later in that year, the customer upgraded the plan to pro annual.

#### Customer 18

Started on trial on Jul 06th, 2020, and after the 7 days of trial it automatically continued to pro monthly.

#### Customer 19

Started on trial on Jun 22nd, 2020, and after the 7 days of trial it automatically continued to pro monthly until later that year the customer upgraded the plan to pro annual.
