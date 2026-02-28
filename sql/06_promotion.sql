-- ==========================================
-- 06_promotion_detection.sql
-- Detect abnormal demand spikes
-- ==========================================

USE retail_db;

-- Daily aggregation
WITH daily_sales AS (
    SELECT
        StockCode,
        DATE(InvoiceDate_parsed) AS sales_date,
        SUM(Quantity) AS daily_qty
    FROM online_retail
    WHERE Quantity > 0
    GROUP BY StockCode, DATE(InvoiceDate_parsed)
),

avg_demand AS (
    SELECT
        StockCode,
        AVG(daily_qty) AS avg_daily_demand
    FROM daily_sales
    GROUP BY StockCode
)

SELECT
    d.StockCode,
    d.sales_date,
    d.daily_qty,
    a.avg_daily_demand,
    d.daily_qty / NULLIF(a.avg_daily_demand,0) AS uplift_ratio
FROM daily_sales d
JOIN avg_demand a
    ON d.StockCode = a.StockCode
WHERE d.daily_qty > 3 * a.avg_daily_demand;