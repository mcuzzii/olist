COPY staging.dated_municipalities
FROM '/app/data/dated_municipalities.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);