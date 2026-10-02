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