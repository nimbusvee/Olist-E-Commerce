DROP MATERIALIZED VIEW IF EXISTS silver_customers;
CREATE MATERIALIZED VIEW silver_customers AS
SELECT
	customer_id::TEXT,
	customer_unique_id::TEXT,
	customer_zip_code_prefix::TEXT,
	customer_city::TEXT,
	customer_state::TEXT
FROM bronze_customers;
CREATE UNIQUE INDEX idx_silver_customers_pk ON silver_customers (customer_id);
CREATE INDEX idx_silver_customers_unique_person ON silver_customers (customer_unique_id);
CREATE INDEX idx_silver_customers_zip ON silver_customers (customer_zip_code_prefix);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_geolocation;
CREATE MATERIALIZED VIEW silver_geolocation AS
SELECT
	geolocation_zip_code_prefix::TEXT,
	geolocation_lat::DOUBLE PRECISION,
	geolocation_lng:: DOUBLE PRECISION
FROM bronze_geolocation;
CREATE INDEX idx_silver_geolocation_zip ON silver_geolocation (geolocation_zip_code_prefix);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_order_items;
CREATE MATERIALIZED VIEW silver_order_items AS
SELECT
	order_id::TEXT,
	order_item_id::INT,
	product_id::TEXT,
	seller_id::TEXT,
	shipping_limit_date::TIMESTAMP,
	price::NUMERIC(10,2),
	freight_value::NUMERIC(10,2)
FROM bronze_order_items;
CREATE UNIQUE INDEX idx_silver_order_items_pk ON silver_order_items (order_id, order_item_id);
CREATE INDEX idx_silver_order_items_product ON silver_order_items (product_id);
CREATE INDEX idx_silver_order_items_seller ON silver_order_items (seller_id);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_order_payments;
CREATE MATERIALIZED VIEW silver_order_payments AS
SELECT
	order_id::TEXT,
	payment_sequential::INT,
	payment_type::TEXT,
	payment_installments::INT,
	payment_value::NUMERIC(10,2)
FROM bronze_order_payments;
CREATE UNIQUE INDEX idx_silver_order_payments_pk ON silver_order_payments (order_id, payment_sequential);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_order_reviews;
CREATE MATERIALIZED VIEW silver_order_reviews AS
SELECT
	review_id::TEXT,
	order_id::TEXT,
	review_score::INT,
	review_comment_title::TEXT,
	review_comment_message::TEXT,
	review_creation_date::DATE,
	review_answer_timestamp::TIMESTAMP
FROM bronze_order_reviews;
CREATE UNIQUE INDEX idx_silver_order_reviews_pk ON silver_order_reviews (review_id, order_id);
CREATE INDEX idx_silver_order_reviews_order ON silver_order_reviews (order_id);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_orders;
CREATE MATERIALIZED VIEW silver_orders AS
SELECT
	order_id::TEXT,
	customer_id::TEXT,
	order_status::TEXT,
	order_purchase_timestamp::TIMESTAMP,
	order_approved_at::TIMESTAMP AS order_approved_timestamp,
	order_delivered_carrier_date::TIMESTAMP AS order_delivered_carrier_timestamp,
	order_delivered_customer_date::TIMESTAMP AS order_delivered_customer_timestamp,
	order_estimated_delivery_date::DATE
FROM bronze_orders;
CREATE UNIQUE INDEX idx_silver_orders_pk ON silver_orders (order_id);
CREATE INDEX idx_silver_orders_customer ON silver_orders (customer_id);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_products;
CREATE MATERIALIZED VIEW silver_products AS
SELECT
	p.product_id::TEXT,
	COALESCE(t.product_category_name_english::TEXT, 'Unknown Category') AS product_category_name,
	p.product_name_lenght::INT AS product_name_length,
	p.product_description_lenght::INT AS product_description_length,
	p.product_photos_qty::INT,
	p.product_weight_g::INT,
	p.product_length_cm::INT,
	p.product_height_cm::INT,
	p.product_width_cm::INT
FROM bronze_products p
LEFT JOIN bronze_category_translation t
    ON p.product_category_name = t.product_category_name;
CREATE UNIQUE INDEX idx_silver_products_pk ON silver_products (product_id);

-- ================================================================================================= --

DROP MATERIALIZED VIEW IF EXISTS silver_sellers;
CREATE MATERIALIZED VIEW silver_sellers AS
SELECT
	seller_id::TEXT,
	seller_zip_code_prefix::TEXT,
	seller_city::TEXT,
	seller_state::TEXT
FROM bronze_sellers;
CREATE UNIQUE INDEX idx_silver_sellers_pk ON silver_sellers (seller_id);
CREATE INDEX idx_silver_sellers_zip ON silver_sellers (seller_zip_code_prefix);