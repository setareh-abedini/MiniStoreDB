-- ============================================================
-- MiniStoreDB - Schema
-- A simple retail database used to practice and demonstrate
-- SQL querying skills (SELECT, JOIN, CTE, window functions, etc.)
-- ============================================================


CREATE SCHEMA retail;
GO

CREATE TABLE retail.customers ( 
	customer_id		INT IDENTITY PRIMARY KEY NOT NULL,
	name			NVARCHAR(100) NOT NULL,
	city			NVARCHAR(100) NOT NULL,
	signup_date		DATE NOT NULL
);
GO


CREATE TABLE retail.products ( 
	product_id		INT IDENTITY PRIMARY KEY NOT NULL,
	product_name	NVARCHAR(100) NOT NULL,
	category		NVARCHAR(100) NOT NULL,
	price			DECIMAL(10,2) NOT NULL
);
GO


CREATE TABLE retail.orders (
	order_id		INT IDENTITY PRIMARY KEY NOT NULL,
	customer_id		INT,
	order_date		DATE NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES retail.customers(customer_id)
);


CREATE TABLE retail.order_items (
	order_item_id	INT IDENTITY PRIMARY KEY,
	order_id		INT NOT NULL,
	product_id		INT NOT NULL,
	quantity		INT NOT NULL,
	FOREIGN KEY (order_id) REFERENCES retail.orders(order_id),
	FOREIGN KEY (product_id) REFERENCES retail.products(product_id)
);
GO


