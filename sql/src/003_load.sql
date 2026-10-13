COPY staging.customers
FROM '/app/data/kaggle/olist_customers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.geolocation
FROM '/app/data/kaggle/olist_geolocation_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_items
FROM '/app/data/kaggle/olist_order_items_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_payments
FROM '/app/data/kaggle/olist_order_payments_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_reviews
FROM '/app/data/kaggle/olist_order_reviews_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.orders
FROM '/app/data/kaggle/olist_orders_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.products
FROM '/app/data/kaggle/olist_products_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.sellers
FROM '/app/data/kaggle/olist_sellers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.product_names
FROM '/app/data/kaggle/product_category_name_translation.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);