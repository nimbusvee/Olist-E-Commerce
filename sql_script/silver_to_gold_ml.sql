DROP TABLE IF EXISTS gold_ml_orders;

CREATE TABLE gold_ml_orders AS
WITH order_items_squashed AS (
    -- compress items into one
    SELECT 
        i.order_id,
        SUM(i.freight_value) AS total_freight_value,
        SUM(p.product_weight_g) AS total_weight_g,
        -- calculate the total volume of the package
        SUM(p.product_length_cm * p.product_height_cm * p.product_width_cm) AS total_volume_cm3,
        -- taking the primary seller from multiple sellers
        MAX(i.seller_id) AS primary_seller_id 
    FROM silver_order_items i
    LEFT JOIN silver_products p ON i.product_id = p.product_id
    GROUP BY i.order_id
),
unique_geospatial AS (
    -- compress lat and lng values as zip codes can have multiple location points
    SELECT 
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS lat,
        AVG(geolocation_lng) AS lng
    FROM silver_geolocation
    GROUP BY geolocation_zip_code_prefix
)

-- order as center point
SELECT 
    o.order_id,
	o.customer_id,
    
    -- target variable: whether a delivery is late or not
    CASE 
        WHEN o.order_delivered_customer_timestamp > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late,
    
    -- the features
    i.total_freight_value,
    i.total_weight_g,
    i.total_volume_cm3,
    
    -- geography points for calculation
    cust_geo.lat AS customer_lat,
    cust_geo.lng AS customer_lng,
    sell_geo.lat AS seller_lat,
    sell_geo.lng AS seller_lng

FROM silver_orders o
JOIN order_items_squashed i ON o.order_id = i.order_id
LEFT JOIN silver_customers c ON o.customer_id = c.customer_id
LEFT JOIN silver_sellers s ON i.primary_seller_id = s.seller_id

-- joining in the unique location
LEFT JOIN unique_geospatial cust_geo ON c.customer_zip_code_prefix = cust_geo.geolocation_zip_code_prefix
LEFT JOIN unique_geospatial sell_geo ON s.seller_zip_code_prefix = sell_geo.geolocation_zip_code_prefix

-- onnly taking completed delivery
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_timestamp IS NOT NULL;