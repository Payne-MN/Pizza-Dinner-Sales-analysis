
/*
SQL Case study project
*/


use pizza_sql;

-- let's  import the csv files
-- Now understand each table (all columns)
select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas; -- pizza_id, pizza_type_id, size, price

select * from orders;

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

/*
Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.

*/


-- Retrieve the total number of orders placed.
select count(distinct order_id) as 'Total Orders' 
from orders;


-- Calculate the total revenue generated from pizza sales.

-- to see the details
select order_details.pizza_id, order_details.quantity, pizzas.price, pizzas.size
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id;

 


-- to get the answer
select cast(sum(order_details.quantity * pizzas.price)as decimal(10,2))as 'Total Revenue'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id;



-- Identify the highest-priced pizza.
-- using TOP/Limit functions
select pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price'
from pizzas 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc;





select  pizza_types.name as 'Pizza names', cast(pizzas.price as decimal(10,2)) as 'price', pizzas.size
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE pizza_types.name = 'The Greek Pizza'
order by price desc;





-- Identify the most common pizza size ordered.
select pizzas.size, count(distinct order_id) as 'No of Orders', sum(quantity) as 'Total Quantity Ordered' 
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
-- join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizzas.size
order by count(distinct order_id) desc;






-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name as 'Pizza', sum(quantity) as 'Total Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name 
order by sum(quantity) desc;
 

-- List the top 5 most ordered pizza types along with their quantities
SELECT pizza_types.name AS 'Pizza',
       SUM(order_details.quantity) AS 'Total Ordered', 
       cast(SUM(order_details.quantity * pizzas.price) as decimal (10,2)) AS 'Total Sales Price'
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY `Total Sales Price`DESC;



-- List the top most ordered pizza types along with their quantities and most ordered size

SELECT pizza_types.name AS 'Pizza', 
       pizzas.size AS ' Pizza Size',
       SUM(order_details.quantity) AS 'Total Ordered', 
      cast( SUM(order_details.quantity * pizzas.price)as decimal (10,2)) AS 'Total Sales Price $'
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE pizza_types.name = 'The Thai Chicken Pizza'
GROUP BY pizza_types.name, pizzas.size
ORDER BY SUM(order_details.quantity) DESC;














-- Join the necessary tables to find the total quantity of each pizza category ordered and the revenue.

select pizza_types.category, 
sum(order_details.quantity) as 'Total Quantity Ordered',
cast( SUM(order_details.quantity * pizzas.price)as decimal (10,2)) as 'Total sales revenue $'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc;


-- Determine the distribution of orders by hour of the day.

select datepart(hour, time) as 'Hour of the day', count(distinct order_id) as 'No of Orders'
from orders
group by datepart(hour, time) 
order by `No of Orders` desc;

SELECT HOUR(time) AS `Hour of the day`, 
       COUNT(DISTINCT order_id) AS `No of Orders`
FROM orders
GROUP BY HOUR(time)
ORDER BY `No of Orders` DESC; 




-- find the category-wise distribution of pizzas


select category, count(distinct pizza_type_id) as `No of pizzas`
from pizza_types
group by category
order by `No of pizzas`;

-- using limits

SELECT category, 
       COUNT(DISTINCT pizza_type_id) AS `No of pizzas`
FROM pizza_types
GROUP BY category
ORDER BY `No of pizzas` 
LIMIT 5;




-- Calculate the average number of pizzas ordered per day.

with cte as(
select orders.date as `Date`, sum(order_details.quantity) as `Total Pizza Ordered that day`
from order_details
join orders on order_details.order_id = orders.order_id
group by orders.date
)
select avg(`Total Pizza Ordered that day`) as `Avg Number of pizzas ordered per day`  from cte;

-- alternate using subquery


SELECT AVG(`Total Pizza Ordered that day`) AS `Avg Number of pizzas ordered per day` 
FROM 
(
    SELECT orders.date AS `Date`, 
           SUM(order_details.quantity) AS `Total Pizza Ordered that day`
    FROM order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.date
) AS pizzas_ordered;



-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity*pizzas.price) as 'Revenue from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by `Revenue from pizza` desc;

-- try doing it using window functions also


/*
Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.
*/


-- Calculate the percentage contribution of each pizza type to total revenues


select pizza_types.category as 'Category', 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;

-- order by [Revenue from pizza] desc

-- revenue contribution from each pizza by pizza name
select pizza_types.name, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by `Revenue contribution from pizza` desc;




-- Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)
with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as 'Revenue'
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte 
group by date, Revenue;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
-- order by category, name, Revenue desc
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue;



