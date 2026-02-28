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