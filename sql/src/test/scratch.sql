SELECT
    *,
    unaccent(geolocation_city) AS geolocation_city_normalized
FROM (
    SELECT
        zip_code_prefix AS geolocation_zip_code_prefix,
        city AS geolocation_city,
        state AS geolocation_state
    FROM staging.customers
    UNION
    SELECT
        seller_zip_code_prefix AS geolocation_zip_code_prefix,
        seller_city AS geolocation_city,
        seller_state AS geolocation_state
    FROM staging.sellers
)
WHERE geolocation_city ~ '[^[:alpha:]\s]'