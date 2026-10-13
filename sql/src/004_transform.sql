CREATE TABLE develop.geolocation_municipalities AS (
    SELECT
        g.*,
        m.gid,
        m.cd_mun,
        m.nm_mun,
        m.cd_rgi,
        m.nm_rgi,
        m.cd_rgint,
        m.nm_rgint,
        m.cd_uf,
        m.nm_uf,
        m.sigla_uf,
        m.cd_regiao,
        m.nm_regiao,
        m.sigla_rg,
        m.cd_concurb,
        m.nm_concurb,
        m.area_km2
    FROM staging.geolocation g
    LEFT JOIN staging.municipality_mesh m
        ON ST_Covers(
            m.geom,
            ST_SetSRID(
                ST_MakePoint(
                    g.geolocation_lng,
                    g.geolocation_lat
                ), 
            4674)
        )
)