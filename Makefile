.PHONY: run download pipeline test stop clean execute

run:
	docker compose up -d db sql-runner

execute:
	docker compose exec sql-runner \
		bash -c 'for file in /sql/*.sql; do \
			echo "Executing $$file..."; \
			psql -v ON_ERROR_STOP=1 -f "$$file"; \
		done'

download:
	docker compose --profile download up --build downloader

pipeline: download run execute

test:
	docker compose exec sql-runner \
		psql -P pager=off -v ON_ERROR_STOP=1 -f /sql/test/scratch.sql

stop:
	docker compose down

clean:
	docker compose down --volumes