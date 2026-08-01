-- MediCheck AI Sprint 3 PostgreSQL schema
-- The JSON catalog remains a demo seed/fallback. This schema is the durable
-- storage contract for a later repository implementation.

BEGIN;

CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    brand TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Güneş Kremi', 'İlaç')),
    manufacturer TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL,
    usage_instructions TEXT NOT NULL DEFAULT '',
    side_effects TEXT NOT NULL DEFAULT '',
    contraindications TEXT NOT NULL DEFAULT '',
    image_url TEXT NOT NULL DEFAULT '',
    contains_alcohol BOOLEAN,
    contains_fragrance BOOLEAN,
    last_reviewed_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_terms (
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    term_type TEXT NOT NULL CHECK (
        term_type IN (
            'ingredient',
            'active_ingredient',
            'filter_type',
            'skin_type',
            'indication',
            'warning'
        )
    ),
    value TEXT NOT NULL,
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    PRIMARY KEY (product_id, term_type, value)
);

CREATE TABLE IF NOT EXISTS product_sources (
    id BIGSERIAL PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    url TEXT NOT NULL CHECK (url LIKE 'https://%'),
    UNIQUE (product_id, url)
);

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_name_lower ON products(LOWER(name));
CREATE INDEX IF NOT EXISTS idx_products_brand_lower ON products(LOWER(brand));
CREATE INDEX IF NOT EXISTS idx_product_terms_value_lower
    ON product_terms(LOWER(value));

COMMIT;
