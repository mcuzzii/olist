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
FROM staging.geolocation;

INSERT INTO intermediate.municipality_names (
    municipality_name,
    normalized_name
)
WITH alterations AS (
    SELECT
        "NOME_ANTERIOR" AS old_name,
        "NOME_ATUAL" AS new_name
    FROM staging.alterations_2025
    WHERE EXTRACT(YEAR FROM to_date("DATA_OCORRÊNCIA", 'DD/MM/YYYY')) >= 2017
)
SELECT
    m.municipality_name,
    lower(unaccent(m.municipality_name)) as normalized_name
FROM (
    SELECT
        COALESCE(a.old_name, m."municipio-nome") AS municipality_name
    FROM staging.municipalities AS m
    LEFT JOIN alterations AS a ON m."municipio-nome" = a.new_name
) m;

INSERT INTO intermediate.district_names (
    district_name,
    normalized_name
)
SELECT
    "distrito-nome",
    lower(unaccent("distrito-nome"))
FROM staging.districts;

INSERT INTO intermediate.subdistrict_names (
    subdistrict_name,
    normalized_name
)
SELECT
    "subdistrito-nome",
    lower(unaccent("subdistrito-nome"))
FROM staging.subdistricts;

CREATE INDEX municipalities_normalized_name_trgm_idx
ON intermediate.municipality_names
USING gin (normalized_name gin_trgm_ops);

CREATE INDEX districts_normalized_name_trgm_idx
ON intermediate.district_names
USING gin (normalized_name gin_trgm_ops);

CREATE INDEX subdistricts_normalized_name_trgm_idx
ON intermediate.subdistrict_names
USING gin (normalized_name gin_trgm_ops);

SET pg_trgm.similarity_threshold = 0.7;

WITH cities AS (
    SELECT DISTINCT
        lower(unaccent(geolocation_city)) AS normalized_city
    FROM staging.geolocation
)
SELECT
    a.normalized_city,
    m.municipality_name
FROM cities a
CROSS JOIN LATERAL (
    SELECT
        m.municipality_name,
        m.normalized_name
    FROM intermediate.municipality_names m
    WHERE m.normalized_name % a.normalized_city
    ORDER BY word_similarity(
        a.normalized_city,
        m.normalized_name
    ) DESC
    LIMIT 1
) m
WHERE m.normalized_name NOT LIKE a.normalized_city






WITH cep AS MATERIALIZED (
    SELECT
        to_char(c.cep_prefix, 'FM00000') AS cep_prefix,
        m.loc_no AS municipio,
        m.ufe_sg AS uf
    FROM (
        SELECT DISTINCT
            loc_nu,
            left(loc_cep_ini, 5)::integer AS cep_range_bottom,
            left(loc_cep_fim, 5)::integer AS cep_range_top
        FROM public.log_faixa_localidade
        WHERE loc_tipo_faixa = 'T'
    ) r
    CROSS JOIN LATERAL generate_series(
        r.cep_range_bottom,
        r.cep_range_top
    ) AS c(cep_prefix)
    JOIN public.log_localidade m
        ON r.loc_nu = m.loc_nu
),
cep_classified AS MATERIALIZED (
    SELECT
        cep_prefix,
        COUNT(DISTINCT (municipio, uf)) AS municipality_count
    FROM cep
    GROUP BY cep_prefix
),
unique_cep AS (
    SELECT
        c.cep_prefix,
        c.municipio,
        c.uf
    FROM cep c
    JOIN cep_classified x
        ON c.cep_prefix = x.cep_prefix
    WHERE x.municipality_count = 1
),
ambiguous_cep AS (
    SELECT
        c.cep_prefix,
        c.municipio,
        c.uf,
        lower(unaccent(c.municipio)) AS municipio_normalized
    FROM cep c
    JOIN cep_classified x
        ON c.cep_prefix = x.cep_prefix
    WHERE x.municipality_count > 1
)
SELECT
    g.geolocation_zip_code_prefix,
    g.geolocation_city,
    g.geolocation_state,
    g.municipio,
    g.uf
FROM (
    SELECT DISTINCT
        g.geolocation_zip_code_prefix,
        g.geolocation_city,
        g.geolocation_state,
        COALESCE(u.municipio, a.municipio) AS municipio,
        COALESCE(u.uf, a.uf) AS uf
    FROM (
        SELECT
            geolocation_zip_code_prefix,
            geolocation_city,
            geolocation_state,
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
    ) g
    LEFT JOIN unique_cep u
        ON g.geolocation_zip_code_prefix = u.cep_prefix
    LEFT JOIN ambiguous_cep a
        ON g.geolocation_zip_code_prefix = a.cep_prefix
        AND g.geolocation_city_normalized = a.municipio_normalized
        AND g.geolocation_state = a.uf
) g
WHERE g.municipio IS NULL;