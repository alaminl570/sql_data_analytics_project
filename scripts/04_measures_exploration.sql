/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the total sales
SELECT
    SUM (Sales_amount) AS total_sale
FROM Sales;

-- Find how many items are sold
SELECT
    SUM (Quantity) AS total_quantity
FROM sales;


-- Find the average selling price
SELECT
    AVG (Price) AS avg_price
FROM sales;


-- Find the total number of orders
SELECT
    COUNT (DISTINCT order_number) AS total_order
FROM sales;


-- Find the total number of products
SELECT
    COUNT (product_key) AS total_products
FROM products;


-- Find the total number of customers
SELECT 
    COUNT(customer_key) AS total_customer
FROM customers;

-- Find the total number of customers who have placed an order
SELECT 
    COUNT(DISTINCT customer_key) AS total_customer_order
FROM sales;

-- Generate Report that shows all key metrics of the business

SELECT
    'Total Sales' as measure_name,
    SUM (Sales_amount) AS measure_value
FROM Sales
UNION ALL
SELECT
    'Total Qunatity' as measure_name,
    SUM (Quantity) AS measure_value
FROM Sales
UNION ALL
SELECT
    'Average Price' as measure_name,
    AVG (Price) AS measure_value
FROM Sales
UNION ALL
SELECT
    'Total Nr. Order' as measure_name,
    COUNT (DISTINCT Order_number) AS measure_value
FROM Sales
UNION ALL
SELECT
    'Total Nr. Products' as measure_name,
    COUNT (DISTINCT Product_name) AS measure_value
FROM Products
UNION ALL
SELECT
    'Total Nr. Customers' as measure_name,
    COUNT (Customer_key) AS measure_value
FROM Customers;