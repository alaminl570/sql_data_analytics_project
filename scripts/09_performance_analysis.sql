/*
===============================================================================
PRODUCT PERFORMANCE ANALYSIS (YoY & MoM)
===============================================================================
Purpose:
    This query evaluates product sales performance over time by comparing:
        • Current sales vs product historical average
        • Current sales vs previous period sales (YoY / MoM)

    It helps identify:
        - High and low performing products
        - Growth and decline trends
        - Stability over time

Techniques Used:
    - CTE for period-level aggregation
    - Window functions (AVG() OVER, LAG())
    - CASE expressions for performance classification
===============================================================================
*/


/* ==========================================================
   YEARLY PRODUCT PERFORMANCE (Year-over-Year Analysis)
   ========================================================== */

WITH yearly_product_sale AS (
    SELECT
        YEAR(s.order_date) AS order_year,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM sales s
    LEFT JOIN products p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,

    -- Historical average sales per product (across all years)
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

    current_sales 
        - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,

    -- Previous year's sales for YoY comparison
    LAG(current_sales) OVER (
        PARTITION BY product_name 
        ORDER BY order_year
    ) AS py_sales,

    current_sales 
        - LAG(current_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ) AS diff_py,

    CASE 
        WHEN current_sales - LAG(current_sales) OVER (
                PARTITION BY product_name ORDER BY order_year
             ) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (
                PARTITION BY product_name ORDER BY order_year
             ) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sale
ORDER BY product_name, order_year;



/* ==========================================================
   MONTHLY PRODUCT PERFORMANCE (Month-over-Month Analysis)
   ========================================================== */

WITH monthy_products_sales AS
(
    SELECT 
        YEAR(s.order_date) AS order_year,        -- Needed to avoid mixing same months across years
        MONTH(s.order_date) AS order_month,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM sales s
    LEFT JOIN products p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), MONTH(s.order_date), p.product_name
)

SELECT
    order_year,
    order_month,
    product_name,
    current_sales,

    -- Historical monthly average per product
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

    current_sales 
        - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg' 
    END AS avg_change,

    -- Previous month's sales within same product
    LAG(current_sales) OVER (
        PARTITION BY product_name 
        ORDER BY order_year, order_month
    ) AS pre_mon_sales,

    current_sales 
        - LAG(current_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year, order_month
        ) AS diff_pre_month,

    CASE 
        WHEN current_sales - LAG(current_sales) OVER (
                PARTITION BY product_name ORDER BY order_year, order_month
             ) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (
                PARTITION BY product_name ORDER BY order_year, order_month
             ) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS pre_month_change

FROM monthy_products_sales
ORDER BY product_name, order_year, order_month;
