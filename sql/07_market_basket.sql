-- ==========================================
-- 07_market_basket.sql
-- Product association mining
-- ==========================================

USE retail_db;

SELECT
    a.StockCode AS product_A,
    b.StockCode AS product_B,
    COUNT(*) AS pair_count
FROM online_retail a
JOIN online_retail b
    ON a.InvoiceNo = b.InvoiceNo
   AND a.StockCode < b.StockCode
WHERE a.Quantity > 0
  AND b.Quantity > 0
GROUP BY a.StockCode, b.StockCode
ORDER BY pair_count DESC
LIMIT 100;