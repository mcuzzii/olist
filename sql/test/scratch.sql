WITH cep AS (
    SELECT DISTINCT
        LEFT(cep, 5) AS cep_prefix,
        municipio,
        uf
    FROM staging.correios_cep
)
SELECT *
FROM (
    SELECT DISTINCT
        g.geolocation_zip_code_prefix,
        g.geolocation_city,
        g.geolocation_state,
        COALESCE(u.municipio, n.municipio) AS municipio,
        COALESCE(u.uf, n.uf) AS uf
    FROM (
        SELECT
            geolocation_zip_code_prefix,
            geolocation_city,
            geolocation_state,
            unaccent(geolocation_city) AS geolocation_city_normalized
        FROM staging.geolocation
    ) g
    LEFT JOIN (
        SELECT
            u.cep_prefix,
            c.municipio,
            c.uf
        FROM (
            SELECT
                cep_prefix
            FROM cep
            GROUP BY cep_prefix
            HAVING COUNT(DISTINCT (municipio, uf)) = 1
        ) u
        LEFT JOIN cep c
            ON u.cep_prefix = c.cep_prefix
    ) u
        ON g.geolocation_zip_code_prefix = u.cep_prefix
    LEFT JOIN (
        SELECT
            n.cep_prefix,
            c.municipio,
            c.uf,
            LOWER(unaccent(c.municipio)) AS municipio_normalized
        FROM (
            SELECT
                cep_prefix
            FROM cep
            GROUP BY cep_prefix
            HAVING COUNT(DISTINCT (municipio, uf)) > 1
        ) n
        LEFT JOIN cep c
            ON n.cep_prefix = c.cep_prefix
    ) n
        ON g.geolocation_zip_code_prefix = n.cep_prefix
        AND g.geolocation_city_normalized = n.municipio_normalized
        AND g.geolocation_state = n.uf
) g
WHERE NOT unaccent(g.geolocation_city) % LOWER(unaccent(g.municipio))