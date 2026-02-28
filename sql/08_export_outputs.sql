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