-- Mamaearth Growth Analytics - SQL Report Queries
USE mamaearth_db;

-- 1. Order Totals & Revenue
SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- 2. Rating Null Check
SELECT 
    COUNT(*) AS total_rows,
    COUNT(rating) as rated_orders,
    COUNT(*) - COUNT(rating) as unrated_orders
FROM orders;

-- 3. Zero-Match Customer Check
SELECT c.customer_id, c.name 
FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
HAVING COUNT(o.order_id) = 0;

-- 4. High Return Rate Cities (> 20%)
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.returned) AS returned_orders,
    ROUND(SUM(o.returned) * 100.0 / COUNT(o.order_id), 1) AS return_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
HAVING return_rate_pct > 20
ORDER BY return_rate_pct DESC;

-- 5. Top 5 Spending Customers
SELECT c.customer_id, c.name, ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- 6. Category-wise Revenue
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 7. Customers starting with 'A'
SELECT * FROM customers WHERE name LIKE 'A%';

-- 8. Distinct Acquisition Sources
SELECT DISTINCT acquisition_source FROM customers;

-- 9. Loyalty Tier Classification
SET SQL_SAFE_UPDATES = 0;
UPDATE customers SET loyalty_tier = CASE WHEN city_tier = 1 THEN 'Gold' ELSE 'Silver' END;
SET SQL_SAFE_UPDATES = 1;
SELECT loyalty_tier, COUNT(*) FROM customers GROUP BY loyalty_tier;