
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
    UNION
    SELECT
        geolocation_zip_code_prefix,
        LOWER(unaccent(TRIM(geolocation_city))) AS geolocation_city,
        geolocation_state
    FROM staging.geolocation
),
alterations AS MATERIALIZED (
    SELECT
        "NOME_ANTERIOR" AS old_name,
        "NOME_ATUAL" AS new_name
    FROM staging.alterations_2025
    WHERE EXTRACT(YEAR FROM to_date("DATA_OCORRÊNCIA", 'DD/MM/YYYY')) >= 2017
),
cep AS MATERIALIZED (
    SELECT
        to_char(c.cep_prefix, 'FM00000') AS cep_prefix,
        m."municipio-nome" AS municipio,
        LOWER(unaccent(TRIM(COALESCE(a.old_name, m."municipio-nome")))) AS municipio_normalized,
        m."UF-sigla" AS uf
    FROM (
        SELECT DISTINCT
            loc_nu,
            left(loc_cep_ini, 5)::integer AS cep_range_bottom,
            left(loc_cep_fim, 5)::integer AS cep_range_top
        FROM public.log_faixa_localidade
    ) r
    CROSS JOIN LATERAL generate_series(
        r.cep_range_bottom,
        r.cep_range_top
    ) c(cep_prefix)
    LEFT JOIN public.log_localidade l
        ON r.loc_nu = l.loc_nu
    LEFT JOIN staging.municipalities m
        ON l.mun_nu::text = m."municipio-id"
    LEFT JOIN alterations a
        ON m."municipio-nome" = a.new_name
),
districts AS MATERIALIZED (
    SELECT
        LOWER(unaccent(TRIM(d."distrito-nome"))) AS distrito,
        d."municipio-nome" AS municipio,
        LOWER(unaccent(TRIM(COALESCE(a.old_name, d."municipio-nome")))) AS municipio_normalized,
        d."UF-sigla" AS uf
    FROM staging.districts d
    LEFT JOIN alterations a
        ON d."municipio-nome" = a.new_name
)
SELECT DISTINCT
    COALESCE(c2.cep_prefix, c1.cep_prefix) AS cep_prefix,
    COALESCE(c2.municipio, c1.municipio) AS municipio,
    g.geolocation_city,
    COALESCE(c2.uf, c1.uf) AS uf
FROM geo g
LEFT JOIN cep c1
    ON g.geolocation_zip_code_prefix = c1.cep_prefix
    AND g.geolocation_city = c1.municipio_normalized
    AND g.geolocation_state = c1.uf
LEFT JOIN districts d
    ON c1.municipio IS NULL
    AND g.geolocation_city = d.distrito
    AND g.geolocation_state = d.uf
LEFT JOIN cep c2
    ON g.geolocation_zip_code_prefix = c2.cep_prefix
    AND d.municipio_normalized = c2.municipio_normalized
    AND g.geolocation_state = c2.uf
WHERE COALESCE(c2.cep_prefix, c1.cep_prefix) IS NULL