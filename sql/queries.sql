-- Q1: Preview orders
SELECT * FROM olist_orders LIMIT 10;

-- Q2: Delivered orders (filter + order by purchase time)
SELECT * FROM olist_orders
WHERE order_status = 'delivered'
ORDER BY order_purchase_timestamp DESC
LIMIT 20;

-- Q3: Monthly revenue (sum of item prices) and total orders
SELECT date_trunc('month', o.order_purchase_timestamp) AS month,
       SUM(oi.price) AS revenue,
       COUNT(DISTINCT o.order_id) AS num_orders
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Q4: Top 10 product categories by revenue
SELECT p.product_category_name,
       SUM(oi.price) AS revenue,
       COUNT(*) AS items_sold
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Q5: Average delivery time (days) by customer state
SELECT c.customer_state,
       AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))/86400) AS avg_delivery_days
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;

-- Q6: Repeat customer ratio
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS percent_repeat
FROM (
  SELECT customer_id, COUNT(*) AS order_count
  FROM olist_orders
  GROUP BY customer_id
) t;

-- Q7: Payments breakdown by type
SELECT payment_type, COUNT(*) AS payments_count, SUM(payment_value) AS total_value, AVG(payment_installments) AS avg_installments
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_value DESC;

-- Q8: Top 10 sellers by revenue
SELECT s.seller_id, s.seller_city, s.seller_state, SUM(oi.price) AS revenue
FROM olist_order_items oi
JOIN olist_sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY revenue DESC
LIMIT 10;

-- Q9: Average review score by product category (may double-count if order has multiple items)
SELECT p.product_category_name, AVG(r.review_score) AS avg_score, COUNT(r.review_id) AS reviews_count
FROM olist_order_reviews r
JOIN olist_order_items oi ON r.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_score DESC
LIMIT 10;

-- Q10: Average item price by review score
SELECT r.review_score, AVG(oi.price) AS avg_price, COUNT(DISTINCT oi.order_id) AS orders_count
FROM olist_order_reviews r
JOIN olist_order_items oi ON r.order_id = oi.order_id
GROUP BY r.review_score
ORDER BY r.review_score;
