-- ==========================================
-- 01_schema.sql
-- Retail Demand & Inventory Analytics
-- ==========================================

USE retail_db;

DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
    InvoiceNo      VARCHAR(20),
    StockCode      VARCHAR(20),
    Description    TEXT,
    Quantity       INT,
    InvoiceDate    VARCHAR(50),
    UnitPrice      DOUBLE,
    CustomerID     VARCHAR(20),
    Country        VARCHAR(50)
);

-- ==========================================
-- 02_load_data.sql
-- Load raw CSV and parse dates
-- ==========================================

USE retail_db;

LOAD DATA LOCAL INFILE 'G:/retail-demand-inventory-analytics/data/raw/Online Retail.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Add parsed datetime column
ALTER TABLE online_retail
ADD COLUMN InvoiceDate_parsed DATETIME;

-- Adjust format if needed (%m/%d/%Y OR %d-%m-%Y based on dataset)
UPDATE online_retail
SET InvoiceDate_parsed =
STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

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

-- ==========================================
-- Export All Outputs
-- ==========================================

USE retail_db;

SELECT * FROM demand_segment_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/demand_segment.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM inventory_class_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inventory_class.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM sku_matrix_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sku_matrix.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';