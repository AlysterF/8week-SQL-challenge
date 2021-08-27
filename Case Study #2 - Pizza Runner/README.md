<p align="center">
  <img src="https://user-images.githubusercontent.com/11970888/131030154-33168a11-9ff3-4437-8ca4-6766f7b8d8d5.png" width="700" position="center"/>
</p>

## Table of Contents
[Business Case](#businesscase)

[Entity Diagram](#diagram)

[Case Questions](#questions)

[Case Solutions](#solutions)

[8 Week SQL Challenge](#challenge)

[Contact Me](#contact)


<a name="businesscase"/>

## Business Case

Danny had a business idea to create a Pizza Empire! But it's not only a pizza delivery, it's a special pizza delivery Uberized. Danny collected a lot of data to start his new business, and he wants help to explore the data and answer some questions and get some insights that will help the business to be unique and assertive.


<a name="diagram"/>

## Entity Diagram

<p align="center">
  <img src="https://user-images.githubusercontent.com/11970888/131030292-c7ff152e-5ac0-4ca1-957d-03c7e0bfa6f3.png" position="center"/>
</p>

<a name="questions"/>

## Case Questions

In this case study the first challenge is to clean and correct anything wrong with the original tables.
Once the correction is done, the questions were splitted by topics:

<details close>
  <summary> <b> A. Pizza Metrics </b> </summary>
  <br>
  <ol>
    <li>How many pizzas were ordered?</li>
    <li>How many unique customer orders were made?</li>
    <li>How many successful orders were delivered by each runner?</li>
    <li>How many of each type of pizza was delivered?</li>
    <li>How many Vegetarian and Meatlovers were ordered by each customer?</li>
    <li>What was the maximum number of pizzas delivered in a single order?</li>
    <li>For each customer, how many delivered pizzas had at least 1 change and how many had no changes?</li>
    <li>How many pizzas were delivered that had both exclusions and extras?</li>
    <li>What was the total volume of pizzas ordered for each hour of the day?</li>
    <li>What was the volume of orders for each day of the week?</li>
  </ol>
</details>

<details close>
  <summary> <b> B. Runner and Customer Experience </b> </summary>
  <br>
  <ol>
    <li>How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)</li>
    <li>What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?</li>
    <li>Is there any relationship between the number of pizzas and how long the order takes to prepare?</li>
    <li>What was the average distance travelled for each customer?</li>
    <li>What was the difference between the longest and shortest delivery times for all orders?</li>
    <li>What was the average speed for each runner for each delivery and do you notice any trend for these values?</li>
    <li>What is the successful delivery percentage for each runner?</li>
  </ol>
</details>

<details close>
  <summary> <b> C. Runner and Customer Experience </b> </summary>
  <br>
  <ol>
    <li>What are the standard ingredients for each pizza?</li>
    <li>What was the most commonly added extra?</li>
    <li>What was the most common exclusion?</li>
    <li>Generate an order item for each record in the customers_orders table in the format of one of the following:</li>
    <ul>
      <li>Meat Lovers</li>
      <li>Meat Lovers - Exclude Beef</li>
      <li>Meat Lovers - Extra Bacon</li>
      <li>Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers</li>
    </ul>
    <li>Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients</li>
    <ul>
      <li>For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"</li>
    </ul>
    <li>What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?</li>
  </ol>
</details>

<details close>
  <summary> <b> D. Pricing and Rating </b> </summary>
  <br>
  <ol>
    <li>If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?</li>
    <li>What if there was an additional $1 charge for any pizza extras?</li>
    <ul>  
      <li>Add cheese is $1 extra</li>
    </ul>
    <li>The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.</li>
    <li>Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?</li>
    <ul>
        <li>customer_id</li>
        <li>order_id</li>
        <li>runner_id</li>
        <li>rating</li>
        <li>order_time</li>
        <li>pickup_time</li>
        <li>Time between order and pickup</li>
        <li>Delivery duration</li>
        <li>Average speed</li>
        <li>Total number of pizzas</li>
    </ul>
    <li>If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?</li>
  </ol>
</details>

<details close>
  <summary> <b> E. Bonus Question </b> </summary>
  <br>
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
</details>

<a name="solutions"/>

## Case Solutions

[Data cleaning and corrections](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/00%20-%20Table%20Corrections.md)

[A. Pizza Metrics](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/A%20-%20Pizza%20Metrics.md)

[B. Runner and Customer Experience](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/B%20-%20Runner%20and%20Customer%20Experience.md)

[C. Ingredient Optmisation](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/C%20-%20Ingredient%20Optimisation.md)

[D. Pricing and Rating](https://github.com/AlysterF/8week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/D%20-%20Pricing%20And%20Ratings.md)

E. Bonus Question

I didn't create any script for this bonus questions, but I'll leave here a short comment about it:
To add new pizzas, it would not be a problem once the pizza_recipes table has no limit for the number of toppings and the temporary table pizza_ingredients are normalizing every ingredient mentioned in recipes and associating it to pizza id. New orders with new pizzas are going to work fine.

<a name="challenge"/>

## 8 Week SQL Challenge by Danny Ma

The 8 week SQL challenge is an awesome challenge create by Danny Ma from [Data With Danny](https://www.datawithdanny.com/).
You can find everything about this challenge and Danny Ma in the [8 Week SQL Challenge Page](https://8weeksqlchallenge.com/)!

<a name="contact"/>

## Contact Me

Feel free to contact me on [Linkedin](https://www.linkedin.com/in/alysterfernandes/)

