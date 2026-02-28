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