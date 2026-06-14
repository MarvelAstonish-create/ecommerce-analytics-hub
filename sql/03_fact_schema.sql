-- ============================================================================
-- OLIST E-COMMERCE ANALYTICS PLATFORM
-- LAYER 2: FACT TABLES
-- Purpose: Create fact tables with foreign keys to dimensions
-- Created: 2026-06-13
-- ============================================================================

-- Create facts schema
CREATE SCHEMA IF NOT EXISTS facts;

-- ============================================================================
-- FACT_ORDERS: Order-level facts
-- Grain: One row per order
-- Source: stg_orders + stg_customers + stg_geolocation
-- ============================================================================

CREATE TABLE IF NOT EXISTS facts.fact_orders (
    -- Surrogate Key
    order_key SERIAL PRIMARY KEY,
    
    -- Business Key
    order_id VARCHAR(50) NOT NULL UNIQUE,
    
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    
    -- Order Status
    order_status VARCHAR(20),
    
    -- Order Dates
    order_purchase_date DATE,
    order_approved_date DATE,
    order_delivered_carrier_date DATE,
    order_delivered_customer_date DATE,
    order_estimated_delivery_date DATE,
    
    -- Calculated Metrics
    days_to_approval INTEGER,
    days_to_delivery INTEGER,
    on_time_delivery BOOLEAN,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_fact_orders_customer 
        FOREIGN KEY (customer_key) REFERENCES dimensions.dim_customer(customer_key),
    CONSTRAINT fk_fact_orders_date 
        FOREIGN KEY (date_key) REFERENCES dimensions.dim_date(date_key)
);

CREATE INDEX idx_fact_orders_customer_key ON facts.fact_orders(customer_key);
CREATE INDEX idx_fact_orders_date_key ON facts.fact_orders(date_key);
CREATE INDEX idx_fact_orders_status ON facts.fact_orders(order_status);
CREATE INDEX idx_fact_orders_order_id ON facts.fact_orders(order_id);

-- ============================================================================
-- FACT_ORDER_ITEMS: Line item-level facts
-- Grain: One row per order item (order + item sequence)
-- Source: stg_order_items + stg_products + stg_sellers
-- ============================================================================

CREATE TABLE IF NOT EXISTS facts.fact_order_items (
    -- Surrogate Key
    order_item_key SERIAL PRIMARY KEY,
    
    -- Business Keys
    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,
    
    -- Foreign Keys to Dimensions
    product_key INTEGER NOT NULL,
    seller_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    
    -- Order Item Metrics
    price NUMERIC(12, 2),
    freight_value NUMERIC(12, 2),
    total_item_value NUMERIC(12, 2),
    
    -- Shipping Information
    shipping_limit_date DATE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(order_id, order_item_id),
    CONSTRAINT fk_fact_order_items_product 
        FOREIGN KEY (product_key) REFERENCES dimensions.dim_product(product_key),
    CONSTRAINT fk_fact_order_items_seller 
        FOREIGN KEY (seller_key) REFERENCES dimensions.dim_seller(seller_key),
    CONSTRAINT fk_fact_order_items_date 
        FOREIGN KEY (date_key) REFERENCES dimensions.dim_date(date_key)
);

CREATE INDEX idx_fact_order_items_product_key ON facts.fact_order_items(product_key);
CREATE INDEX idx_fact_order_items_seller_key ON facts.fact_order_items(seller_key);
CREATE INDEX idx_fact_order_items_date_key ON facts.fact_order_items(date_key);
CREATE INDEX idx_fact_order_items_order_id ON facts.fact_order_items(order_id);

-- ============================================================================
-- FACT_PAYMENTS: Payment-level facts
-- Grain: One row per payment (order + payment sequence)
-- Source: stg_payments + stg_orders + stg_customers
-- ============================================================================

CREATE TABLE IF NOT EXISTS facts.fact_payments (
    -- Surrogate Key
    payment_key SERIAL PRIMARY KEY,
    
    -- Business Keys
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INTEGER NOT NULL,
    
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    
    -- Payment Details
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC(12, 2),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(order_id, payment_sequential),
    CONSTRAINT fk_fact_payments_customer 
        FOREIGN KEY (customer_key) REFERENCES dimensions.dim_customer(customer_key),
    CONSTRAINT fk_fact_payments_date 
        FOREIGN KEY (date_key) REFERENCES dimensions.dim_date(date_key)
);

CREATE INDEX idx_fact_payments_customer_key ON facts.fact_payments(customer_key);
CREATE INDEX idx_fact_payments_date_key ON facts.fact_payments(date_key);
CREATE INDEX idx_fact_payments_type ON facts.fact_payments(payment_type);
CREATE INDEX idx_fact_payments_order_id ON facts.fact_payments(order_id);

-- ============================================================================
-- FACT_REVIEWS: Review-level facts
-- Grain: One row per review
-- Source: stg_reviews + stg_orders + stg_customers + stg_products
-- ============================================================================

CREATE TABLE IF NOT EXISTS facts.fact_reviews (
    -- Surrogate Key
    review_key SERIAL PRIMARY KEY,
    
    -- Business Keys
    review_id VARCHAR(50) NOT NULL UNIQUE,
    order_id VARCHAR(50) NOT NULL,
    
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL,
    product_key INTEGER,
    date_key INTEGER NOT NULL,
    
    -- Review Metrics
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    
    -- Review Dates
    review_creation_date DATE,
    review_answer_date DATE,
    
    -- Calculated Metrics
    days_to_review INTEGER,
    has_comment BOOLEAN,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT fk_fact_reviews_customer 
        FOREIGN KEY (customer_key) REFERENCES dimensions.dim_customer(customer_key),
    CONSTRAINT fk_fact_reviews_product 
        FOREIGN KEY (product_key) REFERENCES dimensions.dim_product(product_key),
    CONSTRAINT fk_fact_reviews_date 
        FOREIGN KEY (date_key) REFERENCES dimensions.dim_date(date_key)
);

CREATE INDEX idx_fact_reviews_customer_key ON facts.fact_reviews(customer_key);
CREATE INDEX idx_fact_reviews_product_key ON facts.fact_reviews(product_key);
CREATE INDEX idx_fact_reviews_date_key ON facts.fact_reviews(date_key);
CREATE INDEX idx_fact_reviews_score ON facts.fact_reviews(review_score);
CREATE INDEX idx_fact_reviews_order_id ON facts.fact_reviews(order_id);

-- ============================================================================
-- End of fact schema
-- ============================================================================
