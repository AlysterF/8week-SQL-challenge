# 8 Week SQL challenge

The 8 week SQL challenge is a free challenge created by Danny Ma from [Data with Danny](https://www.datawithdanny.com/).
It has 8 funny case studies waiting for awesome SQL query solutions!
If you want to know more about the challenge and Danny Ma (and I really recommend you do), feel free to access the [8 Week SQL Challenge Page](https://8weeksqlchallenge.com/).

<br></br>

<h1 align="center" id="heading"> 🍜 Case Study #1 - Danny's Diner 🍜 </h1>

<p align="center">
  <img src="https://user-images.githubusercontent.com/11970888/130274690-935514f2-87d6-475e-a081-d72cd6fda26b.png" width="500" position="center"/>
</p>

<details close>
  <summary> <b> Case #1 details </b> </summary>

  #### Business Case

  Danny wants to use the data to answer some questions about his customers and have some insights to improve his connection with his customers. He plans on using these insights to help him decide whether he should expand the existing customer loyalt program.
  It was provided a sample of his overall customer data due to privacy issues, but it should be enough to create fully functioning SQL queries. The data is organized in three entities and you can check more about it the entity diagram below.

  <details close>
  <summary> <b> Case questions </b> </summary>
  <br>
    <ol>
      <li>What is the total amount each customer spent at the restaurant?</li>
      <li>How many days has each customer visited the restaurant?</li>
      <li>What was the first item from the menu purchased by each customer?</li>
      <li>What is the most purchased item on the menu and how many times was it purchased by all customers?</li>
      <li>Which item was the most popular for each customer?</li>
      <li>Which item was purchased first by the customer after they became a member?</li>
      <li>Which item was purchased just before the customer became a member?</li>
      <li>What is the total items and amount spent for each member before they became a member?</li>
      <li>If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?</li>
      <li>In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?</li>
    </ol>
  </details>

  #### [My Solution and SQL Files](https://github.com/AlysterF/8week-SQL-challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner)

  #### [Case Study #1 Official Website](https://8weeksqlchallenge.com/case-study-1/)

</details>
  
<br></br>

<h1 align="center" id="heading">🍕 Case Study #2 - Pizza Runner 🍕</h1>

<p align="center">
  <img src="https://user-images.githubusercontent.com/11970888/130286867-b2199ada-bf8a-4a06-ae34-b60e40d10d22.png" width="500" position="center"/>
</p>


<details close>
  <summary> <b> Case #2 details </b> </summary>

  #### Business Case

  Danny had a business idea to create a Pizza Empire! But it's not only a pizza delivery, it's a special pizza delivery *Uberized*.
  Danny collected a lot of data to start his new business, and he wants help to explore the data and answer some questions and get some insights that will help the business to be unique and assertive.


  <!-- menu case 2 -->

  <details close>
  <summary> <b> Case questions </b> </summary>
  <br>


    <!-- submenu 1 -->

    <details close>
    <summary> <b> A. Pizza Metrics </b> </summary>
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


    <!-- submenu 2 -->

    <details close>
    <summary> <b> B. Runner and Customer Experience </b> </summary>
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


    <!-- submenu 3 -->

    <details close>
    <summary> <b> C. Ingredient Optimisation </b> </summary>
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

    <!-- submenu 4 -->
    <details close>
    <summary> <b> D. Pricing and Ratings </b> </summary>
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


    <!-- submenu 5 -->

    <details close>
    <summary> <b> E. Bonus Questions </b> </summary>
      <ol>
        <li>If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu.</li>
      </ol>
    </details> 


  </details>

  #### 🚧 Solutions under construction 🚧 

  #### [Case Study #2 Official Website](https://8weeksqlchallenge.com/case-study-2/)

</details>

#### 🚧 Other cases will be added in the future 🚧
