-- =====================================================================
-- Auto-Initialization Script for Docker PostgreSQL
-- Runs automatically on container first startup
-- =====================================================================

-- Set date style to Month/Day/Year to match Superstore CSV format
SET datestyle = 'ISO, MDY';

-- 1. Create Table Schema
CREATE TABLE IF NOT EXISTS retail_sales (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales NUMERIC(10, 2),
    quantity INT,
    discount NUMERIC(4, 2),
    profit NUMERIC(10, 2)
);

-- 2. Load CSV Data
COPY retail_sales (
    row_id, order_id, order_date, ship_date, ship_mode, customer_id,
    customer_name, segment, country, city, state, postal_code, region,
    product_id, category, sub_category, product_name, sales, quantity,
    discount, profit
)
FROM '/data/superstore_sales.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'WIN1252');
