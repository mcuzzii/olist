COPY staging.customers
FROM '/app/data/olist_customers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.geolocation
FROM '/app/data/olist_geolocation_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_items
FROM '/app/data/olist_order_items_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_payments
FROM '/app/data/olist_order_payments_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_reviews
FROM '/app/data/olist_order_reviews_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.orders
FROM '/app/data/olist_orders_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.products
FROM '/app/data/olist_products_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.sellers
FROM '/app/data/olist_sellers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.product_names
FROM '/app/data/product_category_name_translation.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.subdistricts
FROM '/app/data/subdistricts.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.districts
FROM '/app/data/districts.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.municipalities
FROM '/app/data/municipalities.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations
FROM '/app/data/alterations.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.dated_zips
FROM '/app/data/dated_zips.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.dated_municipalities
FROM '/app/data/dated_municipalities.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);