-- ============================================================
-- MiniStoreDB - Seed Data
-- 100 customers, 20 products, 1000 orders, 3000 order_items
-- ============================================================

-- Customers
	DECLARE @i INT = 1;
	WHILE @i <= 100
	BEGIN
	
	INSERT INTO retail.customers (name, city, signup_date)
	VALUES (
			CONCAT('Customer_', @i),
			CASE ABS(CHECKSUM(NEWID())) % 5
				WHEN 0 THEN 'Tehran'
				WHEN 1 THEN 'Shiraz'
				WHEN 2 THEN 'Tabriz'
				WHEN 3 THEN 'Mashhad'
				ELSE 'Isfahan'
			END,
			DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1000, GETDATE())
		);
		SET @i += 1;
	END;
	GO
	
	-- Products
	INSERT INTO retail.products (product_name, category, price)
	VALUES	
		('iPhone 15','Mobile',1200),
		('Galaxy S24','Mobile',1100),
		('AirPods Pro','Accessory',250),
		('Gaming Mouse','Accessory',70),
		('Mechanical Keyboard','Accessory',120),
		('Dell Laptop','Laptop',1500),
		('MacBook Air','Laptop',1800),
		('Monitor 24 Inch','Monitor',300),
		('Monitor 27 Inch','Monitor',450),
		('USB Cable','Accessory',15),
		('Power Bank','Accessory',40),
		('Smart Watch','Wearable',350),
		('Tablet','Tablet',600),
		('Headphones','Accessory',180),
		('Speaker','Accessory',130),
		('Router','Networking',90),
		('SSD 1TB','Storage',120),
		('SSD 2TB','Storage',220),
		('External HDD','Storage',110),
		('Webcam','Accessory',80);
	GO 	
	
	
	
	-- Orders
	
	DECLARE @j INT =1;
	WHILE @j <= 1000
	BEGIN 
		 INSERT INTO retail.orders (customer_id, order_date)
		   VALUES (
	        ABS(CHECKSUM(NEWID())) % 100 + 1,
	        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
	    );
	    SET @j += 1;
	END;
	GO
	
	
	
	-- Order items
	
	DECLARE @k INT = 1;
	WHILE @k <= 3000
	BEGIN
	    INSERT INTO retail.order_items (order_id, product_id, quantity)
	    VALUES (
	        ABS(CHECKSUM(NEWID())) % 1000 + 1,
	        ABS(CHECKSUM(NEWID())) % 20 + 1,
	        ABS(CHECKSUM(NEWID())) % 5 + 1
	    );
	    SET @k += 1;
	END;
	GO