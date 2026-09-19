# Olist E-Commerce Data Analysis

This project features a SQL pipeline and a Tableau dashboard.

## Running the Pipeline

The entire SQL pipeline can be run with the following command:

```
make pipeline
```

This creates the database schemas `staging` and `analytics`, respectively for the raw data and cleaned data for the Tableau dashboard.

## Other Commands

Running `make pipeline` is only efficient for the first time. This command alone downloads the raw dataset from Kaggle, starts a PostgreSQL client and database accessible through `localhost:5432`, and executes the pipeline. These tasks can be run individually—`make pipeline` is equivalent to running the following commands in the same order:

1. `make download` handles the raw data download (persisting in `data/raw/`),
2. `make run` sets up the PostgreSQL database and client, and starts the session,
3. `make execute` runs the pipeline once.

The session lasts indefinitely after `make run` or `make pipeline` until a call to `make stop` or `make clean`, which both stop the session with the latter additionally removing the associated Docker volumes. The initialization steps (`download` and `run`) need not be repeated within a session; multiple calls to `make execute` can be made to rerun the pipeline multiple times efficiently. Since `make download` persists the data locally, it further need not be repeated even across sessions, only unless the data is modified in `data/raw/`. Thus, to start a new session, `make run` alone suffices.

For experimentation, debugging, and inspection of the database schemas, `make test` runs a custom script that can be edited to run any sequence of SQL commands. The script can be found and edited in `sql/test/scratch.sql`. Note that `make test` (as well as `make execute`) will fail when run without starting a session.