DROP SCHEMA IF EXISTS analytics CASCADE;
DROP SCHEMA IF EXISTS develop CASCADE;
DROP SCHEMA IF EXISTS staging CASCADE;

CREATE SCHEMA staging;
CREATE SCHEMA develop;
CREATE SCHEMA analytics;

CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE FUNCTION normalized_levenshtein(a text, b text)
RETURNS numeric
LANGUAGE SQL
IMMUTABLE
AS $$
    SELECT
        1.0 - (
            levenshtein(a, b)::numeric
            / GREATEST(length(a), length(b))
        );
$$;