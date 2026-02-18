/*
===============================================================================
PRODUCT PERFORMANCE & REVENUE REPORT
===============================================================================
Purpose:
    This query generates a product-level performance report that:

        • Aggregates transactional data per product
        • Measures revenue, demand, and customer reach
        • Classifies products based on revenue performance
        • Calculates lifecycle and profitability KPIs

    The output supports product strategy, pricing decisions,
    revenue optimization, and inventory planning.
===============================================================================
*/


-- ==========================================================
-- 1) Base Layer: Prepare transaction-level product dataset
-- ==========================================================
WITH base_query AS (
    SELECT 
        s.order_number,
        s.order_date,
        s.customer_key,
        s.sales_amount,
        s.quantity,

        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost

    FROM sales s
    LEFT JOIN products p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL  -- Required for time-based KPIs
),


-- ==========================================================
-- 2) Aggregation Layer: Compute product-level metrics
-- ==========================================================
product_aggregations AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        -- Active selling duration (in months)
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,

        MAX(order_date) AS last_order_date,

        COUNT(DISTINCT order_number) AS total_order,
        COUNT(DISTINCT customer_key) AS total_customer,

        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        -- Average selling price per unit (defensive division)
        ROUND(
            AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 
        2) AS avg_selling_price

    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)


-- ==========================================================
-- 3) Final Reporting Layer: Segmentation + KPI Calculation
-- ==========================================================
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,

    last_order_date,

    -- Months since last sale (sales recency indicator)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,

    -- Revenue-based performance classification
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_order,
    total_sales,
    total_quantity,
    total_customer,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_order = 0 THEN total_sales
        ELSE total_sales / total_order
    END AS order_revenue,

    -- Average Monthly Revenue (revenue velocity)
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
        
FROM product_aggregations;
