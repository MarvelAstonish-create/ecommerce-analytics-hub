-- ============================================================================
-- OLIST E-COMMERCE ANALYTICS PLATFORM
-- LAYER 2: DIMENSION TABLES
-- Purpose: Create dimensional tables with surrogate keys
-- Created: 2026-06-13
-- ============================================================================

-- Create dimensions schema
CREATE SCHEMA IF NOT EXISTS dimensions;

-- ============================================================================
-- DIM_DATE: Calendar dimension for temporal analysis
-- Grain: One row per day (2015-2019)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_date (
    -- Surrogate Key
    date_key SERIAL PRIMARY KEY,
    
    -- Date Fields
    calendar_date DATE UNIQUE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day INTEGER NOT NULL,
    day_of_week VARCHAR(10),
    is_weekend BOOLEAN,
    
    -- Descriptive Fields
    year_month VARCHAR(7),        -- Format: YYYY-MM
    year_quarter VARCHAR(7),      -- Format: YYYY-Q1
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_date_calendar ON dimensions.dim_date(calendar_date);
CREATE INDEX idx_dim_date_year_month ON dimensions.dim_date(year_month);

-- ============================================================================
-- DIM_CUSTOMER: Customer master dimension
-- Source: stg_customers + stg_geolocation (joined via zip code)
-- Grain: One row per customer
-- SCD Type 2: Track customer changes over time
-- ============================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_customer (
    -- Surrogate Key
    customer_key SERIAL PRIMARY KEY,
    
    -- Business Keys
    customer_id VARCHAR(50) NOT NULL UNIQUE,
    customer_unique_id VARCHAR(50),
    
    -- Customer Location
    customer_city VARCHAR(100),
    customer_state VARCHAR(2),
    customer_zip_code_prefix VARCHAR(5),
    
    -- Geographic Coordinates
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    
    -- SCD Type 2 Tracking
    is_current BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_customer_id ON dimensions.dim_customer(customer_id);
CREATE INDEX idx_dim_customer_state ON dimensions.dim_customer(customer_state);
CREATE INDEX idx_dim_customer_is_current ON dimensions.dim_customer(is_current);

-- ============================================================================
-- DIM_PRODUCT: Product master dimension
-- Source: stg_products
-- Grain: One row per product
-- ============================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_product (
    -- Surrogate Key
    product_key SERIAL PRIMARY KEY,
    
    -- Business Key
    product_id VARCHAR(50) NOT NULL UNIQUE,
    
    -- Product Category
    product_category_name VARCHAR(100),
    
    -- Product Description
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    
    -- Physical Dimensions
    product_weight_g NUMERIC(12, 2),
    product_length_cm NUMERIC(12, 2),
    product_height_cm NUMERIC(12, 2),
    product_width_cm NUMERIC(12, 2),
    
    -- Volume (calculated in cm³)
    product_volume_cm3 NUMERIC(16, 2),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_product_id ON dimensions.dim_product(product_id);
CREATE INDEX idx_dim_product_category ON dimensions.dim_product(product_category_name);

-- ============================================================================
-- DIM_SELLER: Seller master dimension
-- Source: stg_sellers + stg_geolocation
-- Grain: One row per seller
-- ============================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_seller (
    -- Surrogate Key
    seller_key SERIAL PRIMARY KEY,
    
    -- Business Key
    seller_id VARCHAR(50) NOT NULL UNIQUE,
    
    -- Seller Location
    seller_city VARCHAR(100),
    seller_state VARCHAR(2),
    seller_zip_code_prefix VARCHAR(5),
    
    -- Geographic Coordinates
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_seller_id ON dimensions.dim_seller(seller_id);
CREATE INDEX idx_dim_seller_state ON dimensions.dim_seller(seller_state);

-- ============================================================================
-- DIM_GEOLOCATION: Geographic reference dimension
-- Source: stg_geolocation
-- Grain: One row per zip code
-- ============================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_geolocation (
    -- Surrogate Key
    geolocation_key SERIAL PRIMARY KEY,
    
    -- Business Key (zip code prefix)
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL UNIQUE,
    
    -- Location Details
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2),
    
    -- Geographic Coordinates
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_geolocation_zip ON dimensions.dim_geolocation(geolocation_zip_code_prefix);
CREATE INDEX idx_dim_geolocation_state ON dimensions.dim_geolocation(geolocation_state);
CREATE INDEX idx_dim_geolocation_city ON dimensions.dim_geolocation(geolocation_city);

-- ============================================================================
-- End of dimension schema
-- ============================================================================
