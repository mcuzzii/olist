INSERT INTO analytics.zip_city_state (
    zip_code_prefix,
    city,
    city_normalized,
    state
)
SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_city,
    unaccent(geolocation_city) as geolocation_city_normalized,
    geolocation_state
FROM staging.geolocation