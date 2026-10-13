.PHONY: run initialize pipeline execute test stop clean

run:
	docker compose up -d db py-sql

initialize: run
	docker compose exec py-sql sh -c '\
		psql -v ON_ERROR_STOP=1 -f /app/sql/src/001_reset.sql && \
		uv sync --project /app/py && \
		uv run /app/py/src/download.py && \
		shp2pgsql \
			-I \
			-s 4674 \
			-W "UTF-8" /app/data/mun_mesh/BR_Municipios_2025.shp staging.municipality_mesh | psql && \
		psql -v ON_ERROR_STOP=1 -f /app/sql/src/002_schema.sql && \
		psql -v ON_ERROR_STOP=1 -f /app/sql/src/003_load.sql'
	rm -rf ./data/kaggle

pipeline: initialize execute

execute:
	docker compose exec py-sql \
		psql -P pager=off -v ON_ERROR_STOP=1 -f /app/sql/src/004_transform.sql

test:
	docker compose exec py-sql \
		psql -P pager=off -v ON_ERROR_STOP=1 -f /app/sql/src/test/scratch.sql

stop:
	docker compose down

clean:
	docker compose down --volumes