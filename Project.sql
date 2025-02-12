----------------------------------------------!

-- FOOD DELIVERY BUSINESS INSIGHTS PROJECT    !

----------------------------------------------!



-------------------!
-- Creating Tables !
-- ----------------!

CREATE TABLE customers
	(
		customer_id INT PRIMARY KEY,
		customer_name VARCHAR(30),
		reg_date DATE
	);
	

CREATE TABLE resturants
	(
		restaurant_id INT PRIMARY KEY,
		restaurant_name VARCHAR(55),
		city VARCHAR(15),
		opening_hours VARCHAR(55)
	);
	

CREATE TABLE orders
	(
		order_id INT PRIMARY KEY,
		customer_id INT,	-- this column is linked with customers Table
		restaurant_id INT,	-- this column is linked with restaurants Table
		order_item VARCHAR(55),
		order_date DATE,
		order_time TIME,
		order_status VARCHAR(25),
		total_amount FLOAT,
		--adding Foreign Key CONTRAINTS
		CONSTRAINT customer_fk FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
		CONSTRAINT restaurant_fk FOREIGN KEY(restaurant_id) REFERENCES resturants(restaurant_id)
	);


CREATE TABLE riders
	(
		rider_id INT PRIMARY KEY,
		rider_name VARCHAR(55),
		sign_up DATE
	);


CREATE TABLE deliveries
	(
		delivery_id INT PRIMARY KEY,
		order_id INT,		-- this column is linked with orders Table
		delivery_status VARCHAR(35),
		delivery_time TIME,
		rider_id INT,		-- this column is linked with riders Table
		CONSTRAINT orders_fk FOREIGN KEY(order_id) REFERENCES orders(order_id),
		CONSTRAINT riders_fk FOREIGN KEY(rider_id) REFERENCES riders(rider_id)
	);



--------------------!
-- Data Exploration !
-- -----------------!
select * from customers;
select * from resturants;
select * from orders;
select * from riders;
select * from deliveries;



-- ---------------------!
-- BUSINESS PROBLEMS.   !
-- ---------------------!


-- EASY LEVEL QUESTOINS
-- --------------------


-- Q1)
-- (Customer Registration Insights)
-- Retrieve a list of customers who registered between January 1, 2023, and December 31, 2023.

SELECT customer_id,
		customer_name,
		reg_date
FROM customers
WHERE reg_date BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY reg_date ASC;


-- Q2)
-- (Restaurant Search)
-- Find all restaurants located in the city of "Delhi" whose names contain the word "Cafe"

SELECT restaurant_id,
		restaurant_name,
		city,
		opening_hours
FROM resturants
WHERE city = 'Delhi'
AND restaurant_name ILIKE '%Cafe%'
ORDER BY restaurant_name ASC;


-- Q3)
-- (Order Total Calculation)
-- Calculate the total revenue generated from various cities.

SELECT r.city,
	   SUM(o.total_amount) AS total_revenue
FROM resturants as r
	LEFT JOIN orders as o ON r.restaurant_id = o.restaurant_id
WHERE o.total_amount IS NOT NULL
GROUP BY r.city
ORDER BY total_revenue DESC;



-- Q4)
--(Monthly Sales Trend)
--Show the total sales for each month.

SELECT 
	EXTRACT(MONTH FROM order_date) AS order_month,
	TO_CHAR(order_date, 'Month') AS Month_name,
	SUM(total_amount) AS total_sales
FROM orders
GROUP BY 1,2
ORDER BY order_month;


-- Q5) 
-- Order Value Analysis
-- Find the average order value per customer who has placed more than 750 orders.


SELECT 
	c.customer_name,
	AVG(o.total_amount) as aov
FROM orders as o
	LEFT JOIN customers as c ON c.customer_id = o.customer_id
GROUP BY 1
HAVING  COUNT(order_id) > 750
ORDER BY aov DESC;


-- Q6)
-- (Rider Sign-ups)
-- Find the total number of riders who signed up in the last 12 months.

SELECT COUNT(rider_id) AS total_riders
FROM riders
WHERE sign_up >= CURRENT_DATE - INTERVAL '12 months';






-- INTERMEDIATE LEVEL QUESTIONS
-- ----------------------------


-- Q7)
-- (High-Value Customers)
-- List the Top 10 customers who have spent more than 100K in total on food orders.

SELECT 
	c.customer_name,
	SUM(o.total_amount) as total_spent
FROM orders as o
	JOIN customers as c
	ON c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000
ORDER BY total_spent DESC
LIMIT 10;




-- Q8)
-- (Top 5 Most Expensive Orders)
-- Retrieve the top 5 orders based on the highest total_amount, sorted in descending order.
-- Return order_id, customer_name, restaurant_name, total_amount, order_date

SELECT o.order_id,
		c.customer_name,
		r.restaurant_name,
		o.total_amount,
		o.order_date
FROM orders as o
	LEFT JOIN customers as c ON c.customer_id = o.customer_id
	LEFT JOIN resturants as r ON o.restaurant_id = r.restaurant_id
ORDER BY total_amount DESC
LIMIT 5;



-- Q9)
-- (Customer Order Frequency)
-- Determine the number of orders placed by each customer and categorize them as:
-- 'Frequent' (500+ orders),
-- 'Regular' (200-500 orders),
-- 'Occasional' (1-199 orders).

SELECT 
    c.customer_id, 
    c.customer_name, 
    COUNT(o.order_id) AS total_orders,
    CASE 
        WHEN COUNT(o.order_id) > 500 THEN 'Frequent'
        WHEN COUNT(o.order_id) BETWEEN 200 AND 499 THEN 'Regular'
        ELSE 'Occasional'
    END AS order_category
FROM orders as o
JOIN customers as c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;


-- Q10)
-- (Popular Time Slots)
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.


SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;



-- Q11)
-- (Late Deliveries)
-- Get the number of orders delivered late 
-- (where delivery time is greater than order time by more than 60 minutes).

SELECT 
    COUNT(d.delivery_id) AS late_delivery
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_time > (o.order_time + INTERVAL '60 minutes')


-- Q12)
-- (Orders Without Delivery)
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 

SELECT
	r.city,
	r.restaurant_name,
	COUNT(o.order_id) as orders_without_delivery
FROM orders as o
LEFT JOIN 
resturants as r
ON r.restaurant_id = o.restaurant_id
LEFT JOIN
deliveries as d
ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1,2
ORDER BY 3 DESC;


-- Q.13)
-- (Rider Monthly Earnings): 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.


SELECT 
	d.rider_id,
	r.rider_name,
	TO_CHAR(o.order_date, 'Mon YYYY') as month,
	SUM(o.total_amount) as revenue,
	FLOOR(SUM(total_amount)* 0.08) as riders_earning
FROM orders as o
JOIN deliveries as d ON o.order_id = d.order_id
JOIN riders as r ON r.rider_id = d.rider_id	--joining the riders table to get rider_name
GROUP BY 1,2,3
ORDER BY 1,5 DESC





-- ADVANCE LEVEL QUESTIONS
-- -------------------------


-- Q.14)
-- Customer Churn: 
-- Find number of customers who haven’t placed an order in 2024 but did in 2023.


SELECT COUNT(DISTINCT customer_id)
FROM orders
WHERE 
	EXTRACT(YEAR FROM order_date) = 2023		-- customers who placed orders in 2023
	AND
	customer_id NOT IN 							-- customers who did not placed orders in 2024
					(SELECT DISTINCT customer_id FROM orders
					WHERE EXTRACT(YEAR FROM order_date) = 2024)



-- Q.15)
-- (Restaurant Revenue Ranking): 
-- List the top restaurants of each city based on their revenue.


WITH ranking_table AS (
    SELECT 
        r.city,
        r.restaurant_name,
        SUM(o.total_amount) AS revenue,
        RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank
    FROM orders AS o
    JOIN resturants AS r ON r.restaurant_id = o.restaurant_id
    WHERE EXTRACT(YEAR from o.order_date) >= 2023
    GROUP BY r.city, r.restaurant_name
)
SELECT * 
FROM ranking_table
WHERE rank = 1;



-- Q.16)
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.

SELECT * 
FROM
(SELECT 
	r.city,
	o.order_item as dish,
	COUNT(order_id) as total_orders,
	RANK() OVER(PARTITION BY r.city ORDER BY COUNT(order_id) DESC) as rank
FROM orders as o
JOIN 
resturants as r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
) as t1
WHERE rank = 1




-- Q.17)
-- (Order Frequency by Day): 
-- identify the peak day of each restaurant based on Total Orders recieved on each day.

SELECT * FROM
(
	SELECT 
		r.restaurant_name,
		-- o.order_date,
		TO_CHAR(o.order_date, 'Day') as day,
		COUNT(o.order_id) as total_orders,
		RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id)  DESC) as rank
	FROM orders as o
	JOIN
	resturants as r
	ON o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
	) as t1
WHERE rank = 1



-- Q.18)
-- (Order Item Popularity): 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.

SELECT 
	order_item,
	seasons,
	COUNT(order_id) as total_orders
FROM 
(
SELECT 
		*,
		EXTRACT(MONTH FROM order_date) as month,
		CASE 
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 3 AND 6 THEN 'Summer'
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 7 AND 10 THEN 'Monsoon'
			ELSE 'Winter'
		END as seasons
	FROM orders
) as t1
GROUP BY 1,2
ORDER BY 1,3 DESC



-- Q.19)
-- (Top Restaurants by Monthly Revenue)
-- find the top-performing restaurant in terms of revenue for each month of 2023.


WITH MonthlyRevenue AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
		TO_CHAR(o.order_date, 'Month') as Month_Name,
        SUM(o.total_amount) AS total_revenue,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM o.order_date) ORDER BY SUM(o.total_amount) DESC) AS revenue_rank
    FROM orders o
    JOIN resturants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY r.restaurant_id, r.restaurant_name, o.order_date
)
SELECT restaurant_id, restaurant_name, Month_Name, total_revenue
FROM MonthlyRevenue
WHERE revenue_rank = 1
ORDER BY order_month ASC;

