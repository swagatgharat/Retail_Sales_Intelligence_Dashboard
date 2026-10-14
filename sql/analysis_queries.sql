-- =====================================================================
-- Project 1: Sales Data Analysis & Visualization
-- SQL Analysis Script (Compatible with PostgreSQL / MySQL / SQL Server)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Table Schema Creation
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- 2. Data Quality Checks & Validation
-- ---------------------------------------------------------------------

-- Check for total record count
SELECT COUNT(*) AS total_rows FROM retail_sales;

-- Check for duplicates on order line level
SELECT order_id, product_id, COUNT(*) AS duplicate_count
FROM retail_sales
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- Check for missing values in critical columns
SELECT 
    COUNT(*) - COUNT(order_id) AS missing_order_id,
    COUNT(*) - COUNT(order_date) AS missing_order_date,
    COUNT(*) - COUNT(customer_id) AS missing_customer_id,
    COUNT(*) - COUNT(sales) AS missing_sales,
    COUNT(*) - COUNT(profit) AS missing_profit
FROM retail_sales;

-- Check for anomalous values (negative sales, invalid discounts)
SELECT * 
FROM retail_sales 
WHERE sales < 0 OR discount < 0 OR discount > 1;

-- ---------------------------------------------------------------------
-- 3. Core Business KPIs
-- ---------------------------------------------------------------------
SELECT 
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM retail_sales;

-- ---------------------------------------------------------------------
-- 4. Category & Sub-Category Performance (Revenue vs. Profitability)
-- ---------------------------------------------------------------------
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    SUM(quantity) AS total_units_sold,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_pct
FROM retail_sales
GROUP BY category, sub_category
ORDER BY total_profit DESC;

-- Identify loss-making sub-categories (Discount trap analysis)
SELECT 
    sub_category,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_pct
FROM retail_sales
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit ASC;

-- ---------------------------------------------------------------------
-- 5. Seasonal & Monthly Trend Analysis
-- ---------------------------------------------------------------------
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    ROUND(SUM(sales), 2) AS monthly_sales,
    ROUND(SUM(profit), 2) AS monthly_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM retail_sales
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year ASC, order_month ASC;

-- Month-over-Month (MoM) Growth using Window Functions (LAG)
WITH monthly_summary AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(sales) AS revenue
    FROM retail_sales
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    sales_month,
    ROUND(revenue, 2) AS current_month_revenue,
    ROUND(LAG(revenue, 1) OVER (ORDER BY sales_month), 2) AS previous_month_revenue,
    ROUND(
        ((revenue - LAG(revenue, 1) OVER (ORDER BY sales_month)) / 
         NULLIF(LAG(revenue, 1) OVER (ORDER BY sales_month), 0)) * 100, 
        2
    ) AS mom_growth_pct
FROM monthly_summary
ORDER BY sales_month;

-- ---------------------------------------------------------------------
-- 6. Customer Segment & Regional Distribution
-- ---------------------------------------------------------------------
SELECT 
    region,
    segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(SUM(sales), 2) AS regional_sales,
    ROUND(SUM(profit), 2) AS regional_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS margin_pct
FROM retail_sales
GROUP BY region, segment
ORDER BY region, regional_sales DESC;

-- ---------------------------------------------------------------------
-- 7. Top 10 High-Value Customers (Pareto Principle / 80-20 Rule Check)
-- ---------------------------------------------------------------------
SELECT 
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders_placed,
    ROUND(SUM(sales), 2) AS total_spend,
    ROUND(SUM(profit), 2) AS profit_contributed
FROM retail_sales
GROUP BY customer_name, segment
ORDER BY total_spend DESC
LIMIT 10;
