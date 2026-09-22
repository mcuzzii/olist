COPY staging.customers
FROM '/data/raw/olist_customers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.geolocation
FROM '/data/raw/olist_geolocation_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_items
FROM '/data/raw/olist_order_items_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_payments
FROM '/data/raw/olist_order_payments_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.order_reviews
FROM '/data/raw/olist_order_reviews_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.orders
FROM '/data/raw/olist_orders_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.products
FROM '/data/raw/olist_products_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.sellers
FROM '/data/raw/olist_sellers_dataset.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.product_names
FROM '/data/raw/product_category_name_translation.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.subdistricts
FROM '/data/raw/ibge_subdistricts.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.districts
FROM '/data/raw/ibge_districts.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.municipalities
FROM '/data/raw/ibge_municipalities.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2014
FROM '/data/raw/alterations_2014.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2017
FROM '/data/raw/alterations_2017.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2018
FROM '/data/raw/alterations_2018.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2019
FROM '/data/raw/alterations_2019.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2020
FROM '/data/raw/alterations_2020.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2021
FROM '/data/raw/alterations_2021.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2022
FROM '/data/raw/alterations_2022.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2023
FROM '/data/raw/alterations_2023.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2024
FROM '/data/raw/alterations_2024.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY staging.alterations_2025
FROM '/data/raw/alterations_2025.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);