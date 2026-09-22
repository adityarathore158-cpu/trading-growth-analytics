CREATE DATABASE IF NOT EXISTS trading_growth;
USE trading_growth;

CREATE TABLE dim_customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
email VARCHAR(150),
phone VARCHAR(15),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50),
signup_date DATE,
account_type VARCHAR(20),
kyc_status VARCHAR(20),
risk_profile VARCHAR(20),
referral_source VARCHAR(30),
is_active TINYINT
);

CREATE TABLE dim_stocks (
stock_id INT PRIMARY KEY,
symbol VARCHAR(20),
company_name VARCHAR(100),
sector VARCHAR(30),
exchange VARCHAR(10),
isin_code VARCHAR(20),
listing_date DATE,
face_value INT,
base_price DECIMAL(10,2),
market_cap_cr DECIMAL(15,2),
beta DECIMAL(4,2),
is_fno_enabled TINYINT
);

CREATE TABLE dim_date (
date DATE PRIMARY KEY,
day INT,
day_name VARCHAR(15),
month INT,
month_name VARCHAR(15),
quarter INT,
year INT,
is_weekend TINYINT,
is_trading_day TINYINT,
financial_year VARCHAR(10),
week_of_year INT
);

CREATE TABLE fact_orders (
order_id INT PRIMARY KEY,
customer_id INT,
stock_id INT,
order_date DATE,
order_time TIME,
order_type VARCHAR(10),
order_mode VARCHAR(15),
exchange VARCHAR(10),
quantity INT,
price_per_unit DECIMAL(10,2),
gross_amount DECIMAL(15,2),
brokerage_fee DECIMAL(10,2),
tax_amount DECIMAL(10,2),
net_amount DECIMAL(15,2),
order_status VARCHAR(15),
payment_id INT NULL
);

CREATE TABLE fact_payments (
payment_id INT PRIMARY KEY,
order_id INT,
customer_id INT,
payment_date DATE,
payment_amount DECIMAL(15,2),
payment_method VARCHAR(20),
payment_status VARCHAR(15),
transaction_ref VARCHAR(20)
);

# Row Counts
SELECT 'dim_customers', COUNT(*) FROM dim_customers
UNION ALL SELECT 'dim_stocks', COUNT(*) FROM dim_stocks
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_orders', COUNT(*) FROM fact_orders
UNION ALL SELECT 'fact_payments', COUNT(*) FROM fact_payments;

# Add Foreign Keys
ALTER TABLE fact_orders
ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
ADD CONSTRAINT fk_orders_stock FOREIGN KEY (stock_id) REFERENCES dim_stocks(stock_id),
ADD CONSTRAINT fk_orders_date FOREIGN KEY (order_date) REFERENCES dim_date(date);

ALTER TABLE fact_payments
ADD CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES fact_orders(order_id),
ADD CONSTRAINT fk_payments_customer FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id);

# Customer Wise trading Summary
SELECT c.customer_id,c.customer_name,c.city,COUNT(o.order_id) AS total_orders,
COALESCE(SUM(o.quantity), 0) AS total_quantity,
COALESCE(SUM(o.net_amount), 0) AS total_trading_value
FROM dim_customers AS c
LEFT JOIN fact_orders AS o
ON c.customer_id = o.customer_id
AND o.order_status = 'COMPLETED'
GROUP BY c.customer_id,c.customer_name,c.city
ORDER BY total_trading_value DESC;



# Stock Wise Trading Performance
SELECT s.symbol,s.company_name,s.sector,s.exchange,COUNT(o.order_id) AS total_orders,
SUM(o.quantity) AS total_quantity,SUM(o.net_amount) AS total_value
FROM dim_stocks AS s
JOIN fact_orders AS o
ON s.stock_id = o.stock_id
WHERE o.order_status = 'COMPLETED'
GROUP BY s.symbol,s.company_name,s.sector,s.exchange
ORDER BY total_value DESC;


# Orders with their payment status
SELECT o.order_id,o.customer_id,o.order_status,p.payment_status,p.payment_method,p.payment_date
FROM fact_orders AS o
LEFT JOIN fact_payments AS p
ON o.payment_id = p.payment_id
WHERE o.order_status = "COMPLETED"
LIMIT 100;



# Completed Trading Detailed Report
SELECT o.order_id,c.customer_name,s.symbol,s.company_name,d.date,d.month_name,
d.year,o.order_type,o.quantity,o.price_per_unit,o.net_amount,o.order_status
FROM fact_orders AS o
JOIN dim_customers AS c
ON o.customer_id =  c.customer_id
JOIN dim_stocks AS s
ON o.stock_id = s.stock_id
JOIN dim_date AS d
ON o.order_date = d.date
ORDER BY o.order_date,o.order_time;


# Customers whose trading value is above average
SELECT c.customer_id,c.customer_name,SUM(o.net_amount) AS total_trading_value
FROM dim_customers AS c
JOIN fact_orders AS o
ON c.customer_id = o.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.customer_id,c.customer_name
HAVING SUM(o.net_amount) >
(SELECT AVG(customer_total)FROM(
SELECT customer_id,SUM(net_amount) AS customer_total
FROM fact_orders
WHERE order_status = 'COMPLETED'
GROUP BY customer_id) x
);

# Customer trading value using CTE
WITH customer_trading AS
(
SELECT customer_id,SUM(net_amount) AS total_trading_value,COUNT(order_id) AS total_orders
FROM fact_orders
WHERE order_status = "COMPLETED"
GROUP BY customer_id
)
SELECT c.customer_id,c.customer_name,ct.total_trading_value,ct.total_orders
FROM customer_trading AS ct
JOIN dim_customers AS c
ON c.customer_id = ct.customer_id
ORDER BY ct.total_trading_value DESC,ct.total_orders DESC;


# Customer contribution to total trading
WITH customer_sales AS
(
SELECT customer_id,SUM(net_amount) AS customer_value
FROM fact_orders
WHERE order_status = 'COMPLETED'
GROUP BY customer_id
),
total_sales AS 
(
SELECT SUM(customer_value) AS total_value
FROM customer_sales
)
SELECT c.customer_id,c.customer_name,cs.customer_value,
ROUND(cs.customer_value / ts.total_value *100,2) AS contribution_percentage
FROM customer_sales AS cs
JOIN dim_customers AS c
ON cs.customer_id = c.customer_id
CROSS JOIN total_sales AS ts
ORDER BY contribution_percentage DESC;


# Rank customers by trading value
SELECT c.customer_id,c.customer_name,SUM(o.net_amount) AS total_trading_value,
RANK() OVER(ORDER BY SUM(o.net_amount) DESC) AS customer_rank
FROM dim_customers AS c
JOIN fact_orders AS o
ON c.customer_id = o.customer_id
WHERE order_status = "COMPLETED"
GROUP BY c.customer_id,c.customer_name; 


# Stock Ranking by Sector
SELECT s.symbol,s.sector,s.company_name,SUM(o.net_amount) AS total_trading_value,
RANK() OVER(PARTITION BY s.sector ORDER BY SUM(o.net_amount) DESC) AS sector_rank
FROM dim_stocks AS s
JOIN fact_orders AS o
ON s.stock_id = o.stock_id
WHERE order_status = 'COMPLETED'
GROUP BY s.symbol,s.sector,s.company_name;


# Running Trading Value
SELECT order_date,daily_value,
SUM(daily_value) OVER(ORDER BY order_date) AS cumulative_trading_value
FROM
(
SELECT order_date,SUM(net_amount)AS daily_value 
FROM fact_orders
WHERE order_status = 'COMPLETED'
GROUP BY order_date
)x
ORDER BY order_date;


# Month-over-Month Growth
WITH monthly_sales AS
(
SELECT YEAR(order_date) As year,MONTH(order_date) AS month,
SUM(net_amount) AS monthly_value
FROM fact_orders
WHERE order_status = 'Completed'
GROUP BY YEAR(order_date),MONTH(order_date)
),
previous_month AS
(
SELECT year,month,monthly_value,
LAG(monthly_value)OVER(ORDER BY year,month) AS previous_value
FROM monthly_sales
)
SELECT year,month,monthly_value,previous_value,
ROUND((monthly_value-previous_value)/ NULLIF(previous_value,0)*100,2
) AS growth_percentage
FROM previous_month
ORDER BY year,month;


# Successful vs failed payments
SELECT payment_status,
COUNT(payment_id) AS total_payments,
SUM(payment_amount) AS total_payment_value
FROM fact_payments 
GROUP BY payment_status
ORDER BY total_payment_value DESC;

# Find Unpaid Orders
SELECT o.order_id,c.customer_name,o.net_amount,o.order_status
FROM fact_orders o
JOIN dim_customers c
ON o.customer_id = c.customer_id
LEFT JOIN fact_payments p
ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

# Customer trading report
DELIMITER //

CREATE PROCEDURE GetCustomerTrading(IN p_customer_id INT)
BEGIN
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS total_orders,
COALESCE(SUM(o.quantity), 0) AS total_quantity,
COALESCE(SUM(o.net_amount), 0) AS total_trading_value
FROM dim_customers c
LEFT JOIN fact_orders o
ON c.customer_id = o.customer_id
AND o.order_status = 'COMPLETED'
WHERE c.customer_id = p_customer_id
GROUP BY c.customer_id,c.customer_name;
END //
DELIMITER ;

CALL GetCustomerTrading(101);
CALL GetCustomerTrading(102);
CALL GetCustomerTrading(103);


# Date-wise Trading
DELIMITER //
CREATE PROCEDURE GetTradingByDate(IN p_start_date DATE,IN p_end_date DATE)
BEGIN
SELECT order_date,COUNT(order_id) AS total_orders,SUM(quantity) AS total_quantity,SUM(net_amount) AS total_trading_value
FROM fact_orders
WHERE order_date BETWEEN p_start_date AND p_end_date
AND order_status = 'COMPLETED'
GROUP BY order_date
ORDER BY order_date;
END //
DELIMITER ;

CALL GetTradingByDate('2026-01-01', '2026-03-31');


