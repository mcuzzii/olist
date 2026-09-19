# Olist E-Commerce Data Analysis

This project features a SQL pipeline and a Tableau dashboard.

## Installation

Run this once every time you want to start the SQL session.

```
docker compose up -d db
```

In order to download the raw data source, run the following command only once.

```
docker compose --profile tools run --rm downloader
```

This downloads the raw data into `data/raw/`. There's no need to run this again for subsequent work sessions as long as no modifications are made to the download; otherwise, running the command again restores the data.

To run the SQL pipeline itself, run the following command.

```
docker compose run --rm sql-runner
```

The pipeline creates both `staging` and `analytics` schemas in the local PostgreSQL server accessible through `localhost:5432`. The `staging` schema contains the raw data structure, whereas the `analytics` schema contains the transformed data for the Tableau dashboard.