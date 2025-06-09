# Load environment variables from .env file
ifneq (,$(wildcard .env))
include .env
export
endif

# Use API_DB_DSN from .env or fall back to default
DB_DSN ?= $(LOCAL_DB_DSN)
DB_DSN ?= postgres://postgres:postgres@localhost:5433/tesseral?sslmode=disable

.PHONY: bootstrap
bootstrap:
	@# Shut down and clear out any local postgres state
	docker compose stop postgres
	rm -rf .local/postgres
	@# Install the required ssl certs
	./bin/create-localhost-certs
	@# Start the database docker container
	docker compose up -d --wait postgres
	@# Wait for the database to be ready
	@until psql "$(DB_DSN)" -c "SELECT 1" >/dev/null 2>&1; do \
		echo "PostgreSQL is unavailable - retrying..."; \
		sleep 2; \
	done
	@# Run database migrations
	make migrate up
	@# Seed the database
	psql "$(DB_DSN)" -f .local/db/seed.sql
	@# Stop the docker containers
	docker compose stop postgres

.PHONY: seed
seed:
	psql "$(DB_DSN)" -f .local/db/seed.sql

.PHONY: cleanup
cleanup:
	psql "$(DB_DSN)" -f .local/db/cleanup.sql

.PHONY: hosts
hosts:
	./bin/update-hosts

.PHONY: dev
dev:
	docker compose up --build --watch

.PHONY: migrate
ARGS = $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
migrate:
	migrate -path cmd/openauthctl/migrations -database "$(DB_DSN)" $(ARGS)
%:
	@:

.PHONY: proto
proto:
	rm -rf internal/backend/gen internal/frontend/gen internal/intermediate/gen internal/common/gen console/src/gen vault-ui/src/gen
	buf format internal/backend/proto -w
	buf format internal/frontend/proto -w
	buf format internal/intermediate/proto -w
	buf format internal/common/proto -w
	npx buf generate --template buf/buf.gen-backend.yaml
	npx buf generate --template buf/buf.gen-frontend.yaml
	npx buf generate --template buf/buf.gen-intermediate.yaml
	npx buf generate --template buf/buf.gen-common.yaml

.PHONY: queries
queries:
	rm -rf internal/store/queries internal/backend/store/queries internal/frontend/store/queries internal/intermediate/store/queries internal/saml/store/queries internal/scim/store/queries internal/common/store/queries internal/wellknown/store/queries internal/configapi/store/queries
	docker run --rm --volume "$$(pwd)/sqlc/queries.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-backend.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-frontend.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-intermediate.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-saml.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-scim.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-common.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-wellknown.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	docker run --rm --volume "$$(pwd)/sqlc/queries-configapi.sql:/work/queries.sql" backplane/pgformatter -i queries.sql
	sqlc -f ./sqlc/sqlc.yaml generate
