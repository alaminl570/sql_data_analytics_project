/*
===============================================================================
DATA SEGMENTATION ANALYSIS
===============================================================================
Purpose:
    This script performs two segmentation analyses:

    1) Product Segmentation:
       - Classifies products into cost ranges.
       - Counts how many products fall into each range.

    2) Customer Segmentation:
       - Classifies customers based on lifespan and total spending.
       - Categorises them as VIP, Regular, or New.
       - Counts customers in each segment.

    This supports pricing strategy, inventory planning,
    and customer relationship management decisions.
===============================================================================
*/


/* ==========================================================
   PRODUCT COST SEGMENTATION
   ========================================================== */

WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM products
)

SELECT 
    cost_range,
    COUNT(product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC;  -- Highest concentration segment first



/* ==========================================================
   CUSTOMER SEGMENTATION BASED ON SPENDING & LIFESPAN
   ========================================================== */

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,
        MIN(s.order_date) AS first_order,
        MAX(s.order_date) AS last_order,

        -- Customer active duration measured in months
        DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) AS lifespan

    FROM sales s
    LEFT JOIN customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
