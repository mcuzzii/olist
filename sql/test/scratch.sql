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
) m