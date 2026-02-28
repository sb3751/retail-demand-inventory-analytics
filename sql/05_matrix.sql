-- ==========================================
-- 05_sku_matrix.sql
-- Demand vs Inventory matrix
-- ==========================================

USE retail_db;

CREATE OR REPLACE VIEW sku_matrix_view AS
SELECT
    d.StockCode,
    d.demand_segment,
    i.inventory_class
FROM demand_segment_view d
JOIN inventory_class_view i
    ON d.StockCode = i.StockCode;