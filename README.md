# Olist E-Commerce Data Analysis

This project features a SQL pipeline and a Tableau dashboard.

## Installation

In order to download the raw data source, run the following command only once.

```
docker compose --profile tools run --rm downloader
```

This downloads the raw data into `data/raw/`. There's no need to run this again for subsequent work sessions as long as no modifications are made to the download; otherwise, running the command again restores the data.

## Running the Pipeline

To run the SQL pipeline itself, run the following command.

```
docker compose run --rm sql-runner
```

The pipeline creates both `staging` and `analytics` schemas in the local PostgreSQL server accessible through `localhost:5432`. The `staging` schema contains the raw data structure, whereas the `analytics` schema contains the transformed data for the Tableau dashboard.

## Testing

If you want to test your own scripts to inspect both `staging` and `analytics` schemas, you may write your own scripts in `sql/test/scratch.sql' and run the following command:

```
docker compose run --rm sql-runner psql -v ON_ERROR_STOP=1 -f /sql/test/scratch.sql
```