/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

--- Determine the first and last order date 
-- How many years of sales are avaiable

SELECT
    MIN (Order_date) AS First_order_date,
    MAX (Order_date) AS Last_order_date,
    DATEDIFF (year, MIN(order_date), MAX(order_date)) AS order_range_years,
    DATEDIFF (month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM Sales;

--- Find the youngest and oldest customers

SELECT
    MIN(Birthdate) AS Oldest_customer,
    DATEDIFF (year, MIN(Birthdate), GETDATE()) AS Oldest_age,
    MAX(Birthdate) AS Youngest_customer,
    DATEDIFF (year, MAX(Birthdate), GETDATE()) AS Youngest_age
FROM Customers;