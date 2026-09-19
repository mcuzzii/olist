# Olist E-Commerce Data Analysis

This project features a SQL pipeline and a Tableau dashboard.

## Running the Pipeline

The entire SQL pipeline can be run with the following command.

```
make pipeline
```

This creates the database schemas `staging` and `analytics`, respectively for the raw data and cleaned data for the Tableau dashboard.

## Other Commands

Running `make pipeline` is only efficient for the first time. Subsequent reruns of the SQL pipeline can be done by running `make execute` alone.

More specifically, `make pipeline` alone downloads the raw dataset from Kaggle, starts a PostgreSQL database accessible through `localhost:5432` and a client for running the `psql` scripts, and executes the scripts. These tasks can be run individually:

- `make download` handles the raw data download (persisting in `data/raw/`),
- `make run` sets up the PostgreSQL database and client and starts the session,
- `make execute` runs the scripts.

The initialization steps (`download` and `run`) need not be repeated within a session. Since `make download` persists the data locally, new sessions do not need to run `make download`.

For experimentation, debugging, and inspection of the database schemas, `make test` runs a custom script that can be edited to run any sequence of SQL commands. The script can be found and edited in `sql/test/scratch.sql`.

Note that `make execute` and `make test` will fail if run without running the initialization steps.

Running `make stop` ends the session but does not delete the associated Docker volumes. Running `make clean` completes this further step. To start a new session, `make run` suffices.