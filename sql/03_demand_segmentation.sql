-- ==========================================
-- 03_demand_segmentation.sql
-- CV-based demand classification
-- ==========================================

USE retail_db;

CREATE OR REPLACE VIEW demand_segment_view AS
SELECT
    StockCode,
    CASE
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
        ELSE 'Erratic'
    END AS demand_segment
FROM online_retail
WHERE Quantity > 0
GROUP BY StockCode;