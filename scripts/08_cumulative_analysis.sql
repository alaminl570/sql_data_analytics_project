/*
===============================================================================
CUMULATIVE SALES & TREND ANALYSIS
===============================================================================
Purpose:
    This query set calculates aggregated sales metrics (monthly and yearly)
    and applies window functions to compute cumulative totals and moving 
    averages over time. It supports performance tracking and trend analysis.

Key Techniques Used:
    - DATETRUNC() for time-based aggregation
    - GROUP BY for period-level summarization
    - Window functions (SUM() OVER(), AVG() OVER()) for cumulative analysis
===============================================================================
*/

-- ============================================
-- 1. Monthly total sales with cumulative total
-- ============================================
SELECT
    order_date,
    total_sales,
    -- Running total across all months chronologically
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,  -- Normalize to first day of month
        SUM(sales_amount) AS total_sales
    FROM sales
    WHERE order_date IS NOT NULL                    -- Exclude invalid date records
    GROUP BY DATETRUNC(month, order_date)
) t;


-- ==========================================================
-- 2. Monthly sales with partitioned running total (per month)
-- Note: Partitioning by month makes each month its own group,
-- so the running total will equal total_sales per row.
-- ==========================================================
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY order_date 
        ORDER BY order_date
    ) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;


-- ============================================
-- 3. Yearly total sales with cumulative total
-- ============================================
SELECT
    order_date,
    total_sales,
    -- Running total across years
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(year, order_date) AS order_date,  -- Normalize to first day of year
        SUM(sales_amount) AS total_sales
    FROM sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;


-- =====================================================
-- 4. Yearly sales with cumulative total and moving avg
-- =====================================================
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    -- Cumulative moving average of yearly average price
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;
