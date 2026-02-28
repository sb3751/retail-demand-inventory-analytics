USE retail_db;

CREATE TABLE retail_db.online_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DOUBLE,
    CustomerID VARCHAR(20),
    Country VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'G:/retail-demand-inventory-analytics/data/raw/Online Retail.csv'
INTO TABLE retail_db.online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, CustomerID, Country)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate, '%m/%d/%Y %H:%i');

SELECT COUNT(*) FROM retail_db.online_retail;

SELECT * 
FROM retail_db.online_retail
LIMIT 10;

SELECT DISTINCT InvoiceDate
FROM retail_db.online_retail
LIMIT 10;

SHOW CREATE TABLE retail_db.online_retail;

DROP TABLE retail_db.online_retail;

CREATE TABLE retail_db.online_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate VARCHAR(50),
    UnitPrice DOUBLE,
    CustomerID VARCHAR(20),
    Country VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'G:/retail-demand-inventory-analytics/data/raw/Online Retail.csv'
INTO TABLE retail_db.online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT InvoiceDate FROM retail_db.online_retail LIMIT 10;

ALTER TABLE retail_db.online_retail
ADD COLUMN InvoiceDate_parsed DATETIME;

UPDATE retail_db.online_retail
SET InvoiceDate_parsed =
STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i');

SELECT InvoiceDate, InvoiceDate_parsed
FROM retail_db.online_retail
LIMIT 10;

SELECT
    StockCode,
    COUNT(*) AS transactions,
    SUM(Quantity) AS total_demand,
    AVG(Quantity) AS avg_demand
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode
LIMIT 20;

SELECT
    StockCode,
    COUNT(*) AS transactions,
    SUM(Quantity) AS total_demand,
    AVG(Quantity) AS mean_demand,
    STDDEV(Quantity) AS std_demand,
    STDDEV(Quantity) / NULLIF(AVG(Quantity),0) AS cv
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode
LIMIT 20;

SELECT
    StockCode,
    AVG(Quantity) AS mean_demand,
    STDDEV(Quantity)/NULLIF(AVG(Quantity),0) AS cv,
    CASE
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
        ELSE 'Erratic'
    END AS demand_segment
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode
LIMIT 30;

SELECT
    demand_segment,
    COUNT(*) AS sku_count
FROM (
    SELECT
        StockCode,
        CASE
            WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
            WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
            ELSE 'Erratic'
        END AS demand_segment
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode
) t
GROUP BY demand_segment;

SELECT
    StockCode,
    SUM(Quantity) AS total_demand,
    COUNT(*) AS transactions,
    SUM(Quantity)/COUNT(*) AS turnover_proxy
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode
LIMIT 20;

SELECT
    StockCode,
    SUM(Quantity)/COUNT(*) AS turnover_proxy,
    CASE
        WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
        WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
        ELSE 'Slow-moving'
    END AS inventory_class
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode
LIMIT 30;

SELECT
    inventory_class,
    COUNT(*) AS sku_count
FROM (
    SELECT
        StockCode,
        CASE
            WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
            WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
            ELSE 'Slow-moving'
        END AS inventory_class
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode
) t
GROUP BY inventory_class;

SELECT
    v.StockCode,
    v.demand_segment,
    i.inventory_class
FROM
(
    SELECT
        StockCode,
        CASE
            WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
            WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
            ELSE 'Erratic'
        END AS demand_segment
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode
) v
JOIN
(
    SELECT
        StockCode,
        CASE
            WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
            WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
            ELSE 'Slow-moving'
        END AS inventory_class
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode
) i
ON v.StockCode = i.StockCode
LIMIT 30;

SELECT
    demand_segment,
    inventory_class,
    COUNT(*) AS sku_count
FROM
(
    SELECT
        v.StockCode,
        v.demand_segment,
        i.inventory_class
    FROM
    (
        SELECT
            StockCode,
            CASE
                WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
                WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
                ELSE 'Erratic'
            END AS demand_segment
        FROM retail_db.online_retail
        WHERE Quantity > 0
        GROUP BY StockCode
    ) v
    JOIN
    (
        SELECT
            StockCode,
            CASE
                WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
                WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
                ELSE 'Slow-moving'
            END AS inventory_class
        FROM retail_db.online_retail
        WHERE Quantity > 0
        GROUP BY StockCode
    ) i
    ON v.StockCode = i.StockCode
) t
GROUP BY demand_segment, inventory_class;

SELECT
    StockCode,
    DATE(InvoiceDate_parsed) AS sales_date,
    SUM(Quantity) AS daily_qty
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode, DATE(InvoiceDate_parsed)
LIMIT 20;

SELECT
    StockCode,
    AVG(daily_qty) AS avg_daily_demand
FROM
(
    SELECT
        StockCode,
        DATE(InvoiceDate_parsed) AS sales_date,
        SUM(Quantity) AS daily_qty
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode, DATE(InvoiceDate_parsed)
) t
GROUP BY StockCode
LIMIT 20;

SELECT
    d.StockCode,
    d.sales_date,
    d.daily_qty,
    b.avg_daily_demand,
    d.daily_qty / NULLIF(b.avg_daily_demand,0) AS uplift_ratio
FROM
(
    SELECT
        StockCode,
        DATE(InvoiceDate_parsed) AS sales_date,
        SUM(Quantity) AS daily_qty
    FROM retail_db.online_retail
    WHERE Quantity > 0
    GROUP BY StockCode, DATE(InvoiceDate_parsed)
) d
JOIN
(
    SELECT
        StockCode,
        AVG(daily_qty) AS avg_daily_demand
    FROM
    (
        SELECT
            StockCode,
            DATE(InvoiceDate_parsed) AS sales_date,
            SUM(Quantity) AS daily_qty
        FROM retail_db.online_retail
        WHERE Quantity > 0
        GROUP BY StockCode, DATE(InvoiceDate_parsed)
    ) t
    GROUP BY StockCode
) b
ON d.StockCode = b.StockCode
WHERE d.daily_qty > 3 * b.avg_daily_demand
LIMIT 20;

SELECT
    InvoiceNo,
    COUNT(DISTINCT StockCode) AS basket_size
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY InvoiceNo
LIMIT 20;

SELECT
    a.StockCode AS product_A,
    b.StockCode AS product_B,
    COUNT(*) AS pair_count
FROM retail_db.online_retail a
JOIN retail_db.online_retail b
ON a.InvoiceNo = b.InvoiceNo
AND a.StockCode < b.StockCode
WHERE a.Quantity > 0
AND b.Quantity > 0
GROUP BY a.StockCode, b.StockCode
ORDER BY pair_count DESC
LIMIT 20;

CREATE VIEW demand_segment_view AS
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

CREATE VIEW inventory_class_view AS
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

CREATE VIEW sku_matrix_view AS
SELECT
    d.StockCode,
    d.demand_segment,
    i.inventory_class
FROM demand_segment_view d
JOIN inventory_class_view i
ON d.StockCode = i.StockCode;

DROP VIEW demand_segment_view;
DROP VIEW inventory_class_view;
DROP VIEW sku_matrix_view;

CREATE VIEW demand_segment_view AS
SELECT
    StockCode,
    CASE
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) < 0.5 THEN 'Stable'
        WHEN STDDEV(Quantity)/NULLIF(AVG(Quantity),0) BETWEEN 0.5 AND 1 THEN 'Moderate'
        ELSE 'Erratic'
    END AS demand_segment
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode;

CREATE VIEW inventory_class_view AS
SELECT
    StockCode,
    CASE
        WHEN SUM(Quantity)/COUNT(*) > 20 THEN 'Fast-moving'
        WHEN SUM(Quantity)/COUNT(*) BETWEEN 5 AND 20 THEN 'Medium-moving'
        ELSE 'Slow-moving'
    END AS inventory_class
FROM retail_db.online_retail
WHERE Quantity > 0
GROUP BY StockCode;

CREATE VIEW sku_matrix_view AS
SELECT
    d.StockCode,
    d.demand_segment,
    i.inventory_class
FROM demand_segment_view d
JOIN inventory_class_view i
ON d.StockCode = i.StockCode;

SELECT * FROM demand_segment_view LIMIT 10;
SELECT * FROM inventory_class_view LIMIT 10;
SELECT * FROM sku_matrix_view LIMIT 10;

SELECT DATABASE();

USE mysql;
SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';

USE retail_db;

SELECT *
FROM demand_segment_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/demand_segment.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';

SELECT DATABASE();

SELECT * FROM demand_segment_view LIMIT 5;

USE retail_db;

SELECT * FROM demand_segment_view LIMIT 5;

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

CREATE OR REPLACE VIEW sku_matrix_view AS
SELECT
    d.StockCode,
    d.demand_segment,
    i.inventory_class
FROM demand_segment_view d
JOIN inventory_class_view i
ON d.StockCode = i.StockCode;

SELECT DATABASE();

SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';

SELECT * FROM demand_segment_view LIMIT 5;

SELECT *
FROM demand_segment_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/demand_segment.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT *
FROM inventory_class_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inventory_class.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT *
FROM sku_matrix_view
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sku_matrix.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

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
LIMIT 100
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/market_basket.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';