-- ============================================================
-- MiniStoreDB - Business Analysis Queries
-- Each query answers a realistic business question and is
-- tagged with the SQL concept(s) it demonstrates.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Which customers signed up from Tehran?
-- Concepts: SELECT, WHERE, ORDER BY
-- ------------------------------------------------------------
SELECT 
	customer_id, name, city, signup_date
FROM retail.customers
	WHERE city = 'Tehran'
ORDER BY signup_date DESC;


-- ------------------------------------------------------------
-- 2. How many customers do we have per city, and which cities
--    have more than 15 customers?
-- Concepts: GROUP BY, HAVING, COUNT
-- ------------------------------------------------------------
SELECT city, COUNT(*) AS total_customers
FROM retail.customers
GROUP BY city
HAVING COUNT(*) > 15
ORDER BY total_customers DESC;

-- ------------------------------------------------------------
-- 3. What are the top 10 most expensive products?
-- Concepts: SELECT, ORDER BY, TOP
-- ------------------------------------------------------------
SELECT TOP (10) product_name, category, price
FROM retail.products
ORDER BY price DESC;


-- ------------------------------------------------------------
-- 4. Classify products into price tiers (Budget / Mid-range / Premium).
-- Concepts: CASE
-- ------------------------------------------------------------
SELECT
	product_name, price,
	CASE 
		WHEN price < 100 THEN 'Budget'
		WHEN price < 500 THEN 'Mid-range'
		ELSE 'Premium'
	END AS price_tier
FROM retail.products
ORDER BY price;



-- ------------------------------------------------------------
-- 5. Full order details: order id, customer name, product name,
--    quantity and line total.
-- Concepts: JOIN (multiple tables)
-- ------------------------------------------------------------
SELECT 
	O.order_id, c.name AS customer_name, p.product_name, oi.quantity, p.price,
	oi.quantity * p.price AS line_total
FROM retail.orders AS o JOIN retail.customers AS c 
	ON c.customer_id = O.customer_id
	JOIN retail.order_items AS oi
		ON oi.order_id = o.order_id
		JOIN retail.products AS p 
			ON oi.product_id = p.product_id 
ORDER BY o.order_id


-- ------------------------------------------------------------
-- 6. Total revenue generated per product category.
-- Concepts: JOIN, GROUP BY, aggregate function (SUM)
-- ------------------------------------------------------------
SELECT 
	p.category,
	SUM(oi.quantity * p.price ) AS total_revenue
FROM retail.order_items AS oi JOIN retail.products AS p
	ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 7. Customers who have NEVER placed an order.
-- Concepts: SUBQUERY (NOT IN)
-- ------------------------------------------------------------
SELECT 
	c.name AS customer_name
FROM retail.customers AS c
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM retail.orders AS o
										WHERE C.customer_id = O.customer_id)



-- ------------------------------------------------------------
-- 8. Customers whose total spending is above the average
--    customer spending.
-- Concepts: SUBQUERY, CTE, JOIN, aggregate function
-- ------------------------------------------------------------
;WITH customer_spending
AS 
(
	SELECT 
		c.customer_id, c.name,
		SUM(oi.quantity * p.price) AS total_spent
FROM 
	retail.customers AS c JOIN retail.orders AS o
		ON c.customer_id = o.customer_id
 JOIN retail.order_items AS oi 
	ON o.order_id = oi.order_id
	JOIN retail.products AS p 
		ON oi.product_id = p.product_id
	GROUP BY c.customer_id, c.name
)
SELECT 
	customer_id, name, total_spent
FROM 
	customer_spending
	WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending)
ORDER BY total_spent DESC;


-- ------------------------------------------------------------
-- 9. Rank products within each category by total revenue.
-- Concepts: CTE, RANK / DENSE_RANK (window function), JOIN
-- ------------------------------------------------------------
;WITH product_revenue
AS
(
	SELECT 
		p.product_id, p.product_name, p.category,
		SUM(oi.quantity * p.price) AS total_revenue
	FROM retail.order_items AS oi JOIN retail.products AS p
		ON oi.product_id = p.product_id
	GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
	category,
	product_name,
	total_revenue,
	RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY category, revenue_rank;


-- ------------------------------------------------------------
-- 10. Find each customer's most recent order (only the latest one).
-- Concepts: CTE, ROW_NUMBER (window function)
-- ------------------------------------------------------------
;WITH ranked_orders
AS
(
	SELECT
		o.order_id,
		o.customer_id,
		o.order_date,
		ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) AS rn
	FROM retail.orders AS o
)
SELECT 
	customer_id, order_id, order_date
FROM ranked_orders
	WHERE rn = 1
ORDER BY customer_id;


-- ------------------------------------------------------------
-- 11. Monthly revenue trend (year-month, total revenue).
-- Concepts: CTE, GROUP BY, JOIN, date functions
-- ------------------------------------------------------------
;WITH order_revenue
AS
(
	SELECT
		o.order_id,
		FORMAT(o.order_date, 'yyyy-MM') AS order_month,
		(oi.quantity * p.price) AS line_total
	FROM retail.orders AS o JOIN retail.order_items AS oi 
		ON o.order_id = oi.order_id 
		JOIN retail.products AS p 
			ON oi.product_id = p.product_id
)
SELECT 
	order_month,
	SUM(line_total) AS monthly_revenue
FROM order_revenue
GROUP BY order_month
ORDER BY order_month;


-- ------------------------------------------------------------
-- 12. Using set operators (UNION, EXCEPT, INTERSECT), 
-- write a query that combines or compares two sets of values 
-- from your database. Since our retail schema doesn't have two
-- naturally comparable columns, create a simple 
-- demo query — for example, compare the list of customer 
-- cities with the list of product category names — just to 
-- practice the syntax of these operators.
---------------------------------------------------------------

-- Customers who signed up before 2024 UNION customers who spent > 1000
SELECT 
	customer_id, name
FROM retail.customers WHERE signup_date <  '2024-01-01'
UNION
SELECT 
	c.customer_id, c.name
FROM retail.customers AS c JOIN retail.orders AS o 
	ON c.customer_id = o.customer_id
	JOIN retail.order_items AS oi 
		ON o.order_id = oi.order_id
	JOIN retail.products AS p 
		ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name 
HAVING SUM(oi.quantity * p.price) > 1000;

-- Customers who signed up before 2024 EXCEPT customers who never ordered

SELECT 
	customer_id, name
FROM retail.customers AS c 
	WHERE signup_date < '2024-01-01'
EXCEPT
SELECT 
	customer_id, name
FROM retail.customers AS c
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM retail.orders WHERE customer_id IS NOT NULL );


-- ------------------------------------------------------------
-- 13. Top 3 customers by total spending per city.
-- Concepts: CTE, window function (DENSE_RANK), PARTITION BY
-- ------------------------------------------------------------
;WITH customer_spending
AS
(
	SELECT 
		c.customer_id,
		c.name,
		c.city,
		SUM(oi.quantity * p.price ) AS total_spent
	FROM retail.customers AS c JOIN retail.orders AS o 
		ON c.customer_id = o.customer_id
		JOIN retail.order_items AS oi 
			ON o.order_id = oi.order_id
		JOIN retail.products AS p
			ON oi.product_id = p.product_id
		GROUP BY c.customer_id, c.name, c.city
),
ranked 
AS 
(
	SELECT 
		*,
		DENSE_RANK() OVER (PARTITION BY city ORDER BY total_spent DESC) AS city_rank
	FROM customer_spending
)
SELECT 
	city, name, total_spent, city_rank
FROM ranked
WHERE city_rank <= 3
ORDER BY city, city_rank


-- ------------------------------------------------------------
-- 14. Products that have never been ordered (dead stock check).
-- Concepts: SUBQUERY (NOT IN) — could also be solved with 
--           LEFT JOIN + IS NULL, or NOT EXISTS
-- ------------------------------------------------------------
SELECT 
	product_id, product_name, category
FROM retail.products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM retail.order_items);
