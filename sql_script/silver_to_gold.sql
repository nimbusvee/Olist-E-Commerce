DROP TABLE IF EXISTS gold_analytics_items;

CREATE TABLE gold_analytics_items AS

-- Combining different payment_type in an order into one
WITH order_payments_compressed AS (
    SELECT 
        order_id,
        STRING_AGG(DISTINCT payment_type, ', ') AS all_payment_types
    FROM silver_order_payments
    GROUP BY order_id
)

-- order_items as the center point
SELECT 
    -- The items
    i.order_id,
    i.order_item_id,
    i.price AS item_price,
    i.freight_value AS item_freight,
    
    -- The product name translated
    p.product_category_name AS product_category,
    
    -- The order status and timestamps
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_timestamp,
    
    -- Customer demographics & location
    c.customer_unique_id
    
    -- Payment and review
    pay.all_payment_types,
    r.review_score

FROM silver_order_items i
LEFT JOIN silver_orders o 
    ON i.order_id = o.order_id
LEFT JOIN silver_products p 
    ON i.product_id = p.product_id
LEFT JOIN silver_customers c 
    ON o.customer_id = c.customer_id
LEFT JOIN order_payments_compressed pay 
    ON i.order_id = pay.order_id
LEFT JOIN silver_order_reviews r 
    ON i.order_id = r.order_id

-- Keep it to completed business
WHERE o.order_status = 'delivered';