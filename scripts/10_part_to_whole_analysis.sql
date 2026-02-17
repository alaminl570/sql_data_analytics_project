/*
===============================================================================
PART-TO-WHOLE SALES ANALYSIS
===============================================================================
Purpose:
    This query calculates each product category’s contribution to total sales.
    It determines:
        • Total sales per category
        • Overall company sales
        • Percentage contribution of each category

    This supports revenue concentration analysis and category benchmarking.

Techniques Used:
    - CTE for category-level aggregation
    - Window function SUM() OVER() for overall total
    - Percentage calculation using division and rounding
===============================================================================
*/

-- Identify how much each category contributes to total company sales

WITH category_sales AS (
    SELECT
        p.category AS category,
        SUM(s.sales_amount) AS total_sales
    FROM sales s
    LEFT JOIN products p
        ON p.product_key = s.product_key
    GROUP BY p.category
)

SELECT 
    category,
    total_sales,

    -- Overall company sales (same value repeated for each row)
    SUM(total_sales) OVER () AS overall_sale,

    -- Percentage contribution of each category to overall sales
    CONCAT(
        ROUND(
            (CAST(total_sales AS FLOAT) 
            / SUM(total_sales) OVER ()) * 100, 
        2),
    '%') AS percentage_of_sales

FROM category_sales
ORDER BY total_sales DESC;  -- Highest contributing categories first

