-- ----------------------------------------------------------------------------------------------------------
-- --------------------Superstore Sales Relational Data cleaning & Exploratory Data Analysis-----------------
-- -----------------------------------------------------------------------------------------------------------

SELECT *
FROM orders;

-- Duplicating Raw orders
CREATE TABLE Orders_staging
LIKE orders;

INSERT INTO Orders_staging
SELECT *
FROM orders;

SELECT *
FROM orders_staging;

-- Checking duplicates in Orders
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `order_id`,`customer_id`,`order_date`,`year`,`month`,`quarter`,`day_of_week`,`product_name`,category,`unit_price_usd`,quantity, discount_pct, subtotal_usd,shipping_fee_usd,tax_pct,tax_amount_usd,total_amount_usd,payment_method,device_used,delivery_days,delivery_date,order_status,returned,customer_rating,session_duration_minutes,pages_viewed_before_purchase,is_repeat_customer) AS Row_num
FROM orders_staging;

WITH Duplicate_CTE AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `order_id`,`customer_id`,`order_date`,`year`,`month`,`quarter`,`day_of_week`,`product_name`,category,`unit_price_usd`,quantity, discount_pct, subtotal_usd,shipping_fee_usd,tax_pct,tax_amount_usd,total_amount_usd,payment_method,device_used,delivery_days,delivery_date,order_status,returned,customer_rating,session_duration_minutes,pages_viewed_before_purchase,is_repeat_customer) AS Row_num
FROM orders_staging)
SELECT *
FROM Duplicate_CTE
WHERE Row_num>1;
-- Customer table
SELECT *
FROM customers;

-- Checking duplicates
CREATE TABLE customers_staging
LIKE customers;

INSERT INTO customers_staging
SELECT *
FROM customers;

SELECT *,
ROW_NUMBER()OVER(
PARTITION BY customer_id,country,age,gender,membership_tier,registration_date,total_orders,total_spend_usd,avg_order_value_usd,days_since_last_purchase,preferred_category,preferred_device,preferred_payment_method,acquisition_channel,reviews_given,avg_review_score,returns_made,wishlist_items,newsletter_subscribed,churned) AS Row_num
FROM customers;

WITH Duplicate_CTE AS
(SELECT *,
ROW_NUMBER()OVER(
PARTITION BY customer_id,country,age,gender,membership_tier,registration_date,total_orders,total_spend_usd,avg_order_value_usd,days_since_last_purchase,preferred_category,preferred_device,preferred_payment_method,acquisition_channel,reviews_given,avg_review_score,returns_made,wishlist_items,newsletter_subscribed,churned) AS Row_num
FROM customers)
SELECT *
FROM Duplicate_CTE
WHERE Row_num>1;

-- product Summary

SELECT *
FROM product_summary;

CREATE TABLE Product_summary_staging
LIKE product_summary;

INSERT INTO product_summary_staging
SELECT *
FROM product_summary;


SELECT *,
ROW_NUMBER()OVER(
PARTITION BY Category,product_name,total_orders,total_revenue_usd,avg_price,avg_rating,return_rate,avg_discount_pct,avg_delivery_days) AS Row_num
FROM product_summary_staging;

WITH Duplicate_CTE AS
(SELECT *,
ROW_NUMBER()OVER(
PARTITION BY Category,product_name,total_orders,total_revenue_usd,avg_price,avg_rating,return_rate,avg_discount_pct,avg_delivery_days) AS Row_num
FROM product_summary_staging)
SELECT *
FROM Duplicate_CTE
WHERE Row_num >1;

-- Orders
SELECT *
FROM orders_staging;

SELECT order_date, STR_TO_DATE(Order_date,'%Y-%m-%d')
FROM orders_staging;

UPDATE orders_staging
SET order_date=STR_TO_DATE(Order_date,'%Y-%m-%d');

ALTER TABLE orders_staging
MODIFY COLUMN order_date DATE;

SELECT `delivery_date`,STR_TO_DATE(`delivery_date`,'%Y-%m-%d')
FROM orders_staging;


UPDATE orders_staging
SET `Delivery_date`=STR_TO_DATE(`delivery_date`,'%Y-%m-%d');

ALTER TABLE orders_staging
MODIFY COLUMN `delivery_date` DATE;

-- cUSTOMERS
SELECT *
FROM customers_staging;

SELECT registration_date,STR_TO_DATE(registration_date,'%Y-%m-%d')
FROM customers_staging;

UPDATE customers_staging
SET registration_date=STR_TO_DATE(registration_date,'%Y-%m-%d');

ALTER TABLE customers_staging
MODIFY COLUMN registration_date DATE;

-- EXPLORATORY DATA ANALYSIS

-- Total Revenue

SELECT SUM(tax_amount_usd) AS Total_Revenue
FROM orders_staging;

--  Total Orders
SELECT COUNT(order_id) AS Total_orders
FROM orders_staging;

-- Total Customers
SELECT COUNT(customer_id) AS Total_Customers
FROM customers_staging;

-- Average order value
SELECT AVG(total_amount_usd) AS Average_Order_Value
FROM orders_staging;

-- Average customer age
SELECT Avg(age)
FROM customers_staging;

-- Average customer rating
SELECT MAX(customer_rating),MIN(customer_rating)
FROM orders_staging;
-- The blanks in the customer rating were stored as 0
SELECT *
FROM orders_staging
WHERE customer_rating=0;

-- Total zero ratings

SELECT COUNT(*) AS Zero_Ratings
FROM orders_staging
WHERE customer_rating = 0;

-- Average Customer rating

SELECT ROUND(AVG(NULLIF(customer_rating, 0)), 2) AS Avg_Customer_Rating
FROM orders_staging;


-- Return rate
SELECT ROUND(
SUM(Returned)/
COUNT(DISTINCT order_id)* 100,2) AS Return_rate
FROM orders_staging;

-- Customer Analysis
SELECT Country, COUNT(order_id) AS Total_Customers
FROM customers_staging AS Cus
JOIN orders_staging AS Ord
	ON CUS.customer_id=Ord.customer_id
GROUP BY country
ORDER BY 2 DESC;

-- Gender distribution of our customer base
SELECT gender,COUNT(customer_id) AS Total_Customers
FROM customers_staging 
GROUP BY gender
ORDER BY 2 DESC;

-- Which gender has more customers, places more orders and has the highest revenue

SELECT CUS.gender,
COUNT(ORD.order_id) AS Total_Customers,
ROUND(SUM(ORD.total_amount_usd),2) AS Total_Revenue
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY gender
ORDER BY 2,3 asc;


-- Which age group makes up our customer base

SELECT MAX(age),MIN(age)
FROM customers_staging;

-- Grouping the ages
SELECT AGE,
CASE 
	WHEN AGE<=35 THEN 'Young'
	WHEN AGE<=50 THEN 'Adult'
	WHEN AGE<=60 THEN 'Older Adult'
	ELSE 'Old'
END AS Age_Grouping
FROM customers_staging;

ALTER TABLE customers_staging
ADD COLUMN age_grouping VARCHAR(20);

UPDATE customers_staging
SET age_grouping=CASE 
	WHEN AGE<=35 THEN 'Young'
	WHEN AGE<=50 THEN 'Adult'
	WHEN AGE<=60 THEN 'Older Adult'
	ELSE 'Old'
END;

SELECT CUS.age_grouping, 
COUNT(ORD.order_id)AS Total_orders,
ROUND(SUM(ORD.total_amount_usd),2) AS Total_revenue
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY CUS.age_grouping
ORDER BY 2 DESC,3 DESC;

-- Top 10 customers by spending

SELECT Customer_id, ROUND(SUM(total_amount_usd),2) AS Total_revenue
FROM orders_staging
GROUP BY Customer_id
ORDER BY 2 DESC
LIMIT 10;

-- which categories take customers longer period to browse?
SELECT 
    category,
    ROUND(AVG(`session_duration_minutes`), 2) AS avg_session_duration
FROM orders_staging
GROUP BY category
ORDER BY avg_session_duration DESC;

-- Are customers spending too much time on categories with high revenue?
SELECT 
    category,
    ROUND(AVG(`session_duration_minutes`), 2) AS avg_session_duration,
    ROUND(SUM(total_amount_usd),2) AS Total_Revenue
FROM orders_staging
GROUP BY category
ORDER BY avg_session_duration DESC;

-- Do customers spend lots of session duration minutes on categories with high revenue and do they have many orders?

SELECT 
category,
COUNT(order_id) AS total_orders,
ROUND(AVG(`session_duration_minutes`), 2) AS avg_session_duration,
ROUND(SUM(total_amount_usd), 2) AS total_revenue
FROM orders_staging
GROUP BY category
ORDER BY avg_session_duration DESC;



-- -------PRODUCT ANALYSIS---------
-- Top 15 Performing products
SELECT product_name, 
ROUND(SUM(total_revenue_Usd),2) as Total_Revenue
FROM product_summary_staging
GROUP BY product_name
ORDER BY 2 DESC
LIMIT 15;

-- products with long delivery days
SELECT product_name,avg_delivery_days
FROM product_summary_staging
ORDER BY 2 DESC;

-- Membership with the large customer base and which one brings the highest revenue

SELECT CUS.membership_tier, 
COUNT(CUS.customer_id) AS Total_orders, 
ROUND(SUM(ORD.total_amount_usd),2) AS Total_revenue
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY CUS.membership_tier
ORDER BY 2 desc,3 DESC;

-- Most preferred device
SELECT Preferred_device, COUNT(ORD.customer_id) AS No_of_orders
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY preferred_device
ORDER BY 2 DESC;

-- Best perfoming Acquisition channel
SELECT acquisition_channel, COUNT(ORD.customer_id) AS No_of_orders
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY acquisition_channel
ORDER BY 2 DESC;

-- Preferred Category
SELECT preferred_category, COUNT(ORD.customer_id) AS No_of_orders
FROM customers_staging AS CUS
JOIN orders_staging AS ORD
	ON CUS.customer_id=ORD.customer_id
GROUP BY preferred_category
ORDER BY 2 DESC;

-- Timeline analysis
--  How did the business perform in the years and months

SELECT `YEAR`, 
COUNT(order_id) AS Total_Orders
FROM orders_staging
GROUP BY `YEAR`
ORDER BY 2 DESC ;

SELECT `Year`,`month`, 
COUNT(order_id) AS Total_Orders
FROM orders_staging
GROUP BY `month`,`year`
ORDER BY 1 asc ;

WITH Rolling_Total AS
(SELECT `Year`,`month`, 
COUNT(order_id) AS Total_Orders
FROM orders_staging
GROUP BY `month`,`year`
ORDER BY 1 asc)
SELECT `YEAR`,`MONTH`, Total_Orders, SUM(Total_Orders) OVER (PARTITION BY `YEAR` ORDER BY `MONTH`) AS Rolling_total
FROM Rolling_Total ;


















