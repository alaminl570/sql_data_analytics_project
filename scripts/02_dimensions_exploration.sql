/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

--- Explore all country our customers come from?
SELECT
    DISTINCT Country
FROM Customers;

--- Explore all products categories "The Major Divisions"

SELECT
    DISTINCT Category,
    Subcategory,
    Product_name
FROM Products
WHERE Category IS NOT NULL
ORDER BY Category, Subcategory, Product_name;

