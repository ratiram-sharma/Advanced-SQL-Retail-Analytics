-- ==========================================
-- PROJECT: E-Commerce & Retail Data Pipeline
-- AUTHOR: Ratiram Sharma
-- ==========================================

-- CASE STUDY 1: Customer Cohort Tracking
SELECT o.user_id, u.user_name, o.order_date,
       MIN(order_date) OVER (PARTITION BY o.user_id) AS first_order_date
FROM orders as o
INNER JOIN users as u ON o.user_id = u.user_id
WHERE order_status = 'completed';

-- CASE STUDY 2: RFM Customer Segmentation
WITH customer_metrics AS (
  SELECT user_id,
         MAX(order_date) AS last_order_date,
         COUNT(order_date) AS total_orders,
         SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT *,
       CASE
           WHEN total_spent > 1000 THEN 'VIP'
           WHEN total_spent BETWEEN 500 AND 1000 THEN 'Regular'
           ELSE 'At Risk'
       END as customer_tier
FROM customer_metrics;

-- CASE STUDY 3: Top 3 Highest Grossing Products Per Category
WITH product_sales AS (
  SELECT p.category, p.product_name,
         SUM(o.quantity * o.sale_price) AS product_revenue
  FROM order_items AS o
  JOIN products AS p ON o.product_id = p.product_id
  GROUP BY p.category, p.product_name
),
ranked_products AS (
  SELECT category, product_name, product_revenue,
         DENSE_RANK() OVER (PARTITION BY category ORDER BY product_revenue DESC) AS revenue_rank
  FROM product_sales
)
SELECT * FROM ranked_products
WHERE revenue_rank <= 3;

-- CASE STUDY 4: Supply Chain Optimization & Performance Tuning
CREATE INDEX idx_inventory_status
ON inventory (warehouse_id, stock_count);

CREATE VIEW vw_critical_low_stock AS
SELECT *
FROM inventory
WHERE stock_count < 50;