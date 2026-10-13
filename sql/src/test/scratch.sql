WITH geo AS MATERIALIZED (
    SELECT
        zip_code_prefix AS geolocation_zip_code_prefix,
        LOWER(unaccent(TRIM(city))) AS geolocation_city,
        state AS geolocation_state
    FROM staging.customers
    UNION
    SELECT
        seller_zip_code_prefix AS geolocation_zip_code_prefix,
        LOWER(unaccent(TRIM(seller_city))) AS geolocation_city,
        seller_state AS geolocation_state
    FROM staging.sellers
),
cep AS MATERIALIZED (
    SELECT DISTINCT
        LEFT(z."NU_CEP", 5) AS zip_code_prefix,
        m."NM_MUNIC" AS municipio,
        z."SG_UF" AS uf
    FROM staging.dated_zips z
    LEFT JOIN staging.dated_municipalities m
        ON z."ID_MUNI_PREV" = left(m."ID_MUNIC", 5)
)
SELECT DISTINCT
    g.geolocation_zip_code_prefix,
    g.geolocation_city,
    g.geolocation_state,
    c.municipio,
    c.uf
FROM geo g
LEFT JOIN cep c
    ON g.geolocation_zip_code_prefix = c.zip_code_prefix
WHERE
    NOT g.geolocation_state = c.uf