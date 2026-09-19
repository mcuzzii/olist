# Olist E-Commerce Data Analysis

This project features a SQL pipeline and a Tableau dashboard.

## Running the Pipeline

The entire SQL pipeline can be run with the following command:

```
make pipeline
```

This creates the database schemas `staging` and `analytics`, respectively for the raw data and cleaned data for the Tableau dashboard.

## Other Commands

Running `make pipeline` is only efficient for the first time. This command alone downloads the raw dataset from Kaggle, starts a PostgreSQL client and database accessible through `localhost:5432`, and executes the `psql` scripts. These tasks can be run individually:

- `make download` handles the raw data download (persisting in `data/raw/`),
- `make run` sets up the PostgreSQL database and client and starts the session,
- `make execute` runs the scripts.

The initialization steps (`download` and `run`) need not be repeated within a session. Since `make download` persists the data locally, it further need not be repeated even across sessions, only unless the data is modified in `data/raw/`. Within a session, subsequent reruns of the SQL pipeline can be done by running `make execute` alone.

Running `make stop` ends the session but does not delete the associated Docker volumes. Running `make clean` completes this further step. To start a new session, `make run` alone suffices given that `make pipeline` or `make download` have been run before.

For experimentation, debugging, and inspection of the database schemas, `make test` runs a custom script that can be edited to run any sequence of SQL commands. The script can be found and edited in `sql/test/scratch.sql`. Note that `make test` (as well as `make execute`) will fail when run without starting a session.