.PHONY: run initialize pipeline execute test stop clean

run:
	docker compose up -d db sql-runner

initialize: run
	docker compose exec sql-runner \
		psql -v ON_ERROR_STOP=1 -f /app/sql/001_reset.sql
	docker compose run --rm data-loader sh -c '\
		python /app/docker/data-loader/download.py && \
		edne-correios-loader load \
			--database-url "postgresql://postgres:$${PG_PASSWORD}@db:5432/olist" \
			--tables all'
	docker compose exec sql-runner \
		psql -v ON_ERROR_STOP=1 -f /app/sql/002_schema.sql
	docker compose exec sql-runner \
		psql -v ON_ERROR_STOP=1 -f /app/sql/003_load.sql
	rm -rf ./olist-data

pipeline: initialize execute

execute:
	docker compose exec sql-runner \
		psql -P pager=off -v ON_ERROR_STOP=1 -f /app/sql/004_transform.sql

test:
	docker compose exec sql-runner \
		psql -P pager=off -v ON_ERROR_STOP=1 -f /app/sql/test/scratch.sql

stop:
	docker compose down

clean:
	docker compose down --volumes