-- ============================================================================
-- OLIST E-COMMERCE ANALYTICS PLATFORM
-- LAYER 1: STAGING SCHEMA
-- Purpose: Load raw CSV data into PostgreSQL with minimal transformation
-- Created: 2026-06-11
-- ============================================================================

-- Create schema for staging tables
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- TABLE 1: stg_orders
-- Purpose: Raw orders data from olist_orders.csv
-- Rows: 99,441
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_orders_customer_id ON staging.stg_orders(customer_id);
CREATE INDEX idx_stg_orders_status ON staging.stg_orders(order_status);
CREATE INDEX idx_stg_orders_purchase_date ON staging.stg_orders(order_purchase_timestamp);

-- ============================================================================
-- TABLE 2: stg_order_items
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_order_items (
    order_item_key SERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    price NUMERIC(12, 2),
    freight_value NUMERIC(12, 2),
    shipping_limit_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, order_item_id)
);

CREATE INDEX idx_stg_order_items_order_id ON staging.stg_order_items(order_id);
CREATE INDEX idx_stg_order_items_product_id ON staging.stg_order_items(product_id);
CREATE INDEX idx_stg_order_items_seller_id ON staging.stg_order_items(seller_id);

-- ============================================================================
-- TABLE 3: stg_customers
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_customers_unique_id ON staging.stg_customers(customer_unique_id);
CREATE INDEX idx_stg_customers_state ON staging.stg_customers(customer_state);
CREATE INDEX idx_stg_customers_zip ON staging.stg_customers(customer_zip_code_prefix);

-- ============================================================================
-- TABLE 4: stg_products
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC(12, 2),
    product_length_cm NUMERIC(12, 2),
    product_height_cm NUMERIC(12, 2),
    product_width_cm NUMERIC(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_products_category ON staging.stg_products(product_category_name);

-- ============================================================================
-- TABLE 5: stg_reviews
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_reviews_order_id ON staging.stg_reviews(order_id);
CREATE INDEX idx_stg_reviews_score ON staging.stg_reviews(review_score);
CREATE INDEX idx_stg_reviews_creation_date ON staging.stg_reviews(review_creation_date);

-- ============================================================================
-- TABLE 6: stg_payments
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_payments (
    payment_key SERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, payment_sequential)
);

CREATE INDEX idx_stg_payments_order_id ON staging.stg_payments(order_id);
CREATE INDEX idx_stg_payments_type ON staging.stg_payments(payment_type);

-- ============================================================================
-- TABLE 7: stg_sellers
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state VARCHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_sellers_state ON staging.stg_sellers(seller_state);

-- ============================================================================
-- TABLE 8: stg_geolocation
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.stg_geolocation (
    geolocation_zip_code_prefix VARCHAR(5) PRIMARY KEY,
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stg_geolocation_city ON staging.stg_geolocation(geolocation_city);
CREATE INDEX idx_stg_geolocation_state ON staging.stg_geolocation(geolocation_state);

-- ============================================================================
-- End of staging schema
-- ============================================================================
