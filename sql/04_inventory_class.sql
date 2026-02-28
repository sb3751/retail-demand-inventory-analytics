-- ==========================================
-- 04_inventory_class.sql
-- Turnover-based inventory classification
-- ==========================================

USE retail_db;

CREATE OR REPLACE VIEW inventory_class_view AS
SELECT
    StockCode,
    CASE
        WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
        WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
        ELSE 'Slow-moving'
    END AS inventory_class
FROM online_retail
WHERE Quantity > 0
GROUP BY StockCode;