SELECT
    g.*,
    m.cd_mun,
    m.nm_mun,
    m.sigla_uf
FROM staging.geolocation AS g
LEFT JOIN staging.municipality_mesh AS m
    ON ST_Covers(
        m.geom,
        ST_SetSRID(ST_MakePoint(g.geolocation_lng, g.geolocation_lat), 4674)
    );