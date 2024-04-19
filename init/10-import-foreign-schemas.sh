#!/usr/bin/env bash

# This script will set up foreign data servers on the target postgresql instance.
# If the target postgres DB is on AWS, make sure it is not a read replica and that the account used to authenticate has appropriate permissions.
# This script needs to be run after the DB is up and running. Utilizing fieldsets-local, you can add this script to the init directory when needed.

set -e

export PRIORITY=10
export PGPASSWORD=${POSTGRES_PASSWORD}
FDFILE="/data/checkpoints/${PRIORITY}-pg-foreign-data-import.complete"

if [[ ! -f "${FDFILE}" ]]; then
    # Postgres
    # Create Local File Server for Imports for scraper outputs.
    psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE SERVER IF NOT EXISTS file_server
            FOREIGN DATA WRAPPER file_fdw;
	EOSQL

    # Always allow external sources to be added after initialization as these should be read only.
    echo "Importing remote postgres data schemas......"

    # Wait for or data store
    if [[ "${ENABLE_STORE:-false}" == "true" ]]; then
        timeout 90s bash -c "until curl --silent --output /dev/null http://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/ping; do printf '.'; sleep 5; done; printf '\n'"

        psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE EXTENSION IF NOT EXISTS clickhouse_fdw;
            CREATE SERVER IF NOT EXISTS clickhouse_server
                FOREIGN DATA WRAPPER clickhouse_fdw
                OPTIONS(dbname '${CLICKHOUSE_DB}', host '${CLICKHOUSE_HOST}', port '${CLICKHOUSE_PORT}');

            CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER clickhouse_server OPTIONS (user '${CLICKHOUSE_USER}', password '${CLICKHOUSE_PASSWORD}');
            CREATE USER MAPPING IF NOT EXISTS FOR ${POSTGRES_TRIGGER_ROLE} SERVER clickhouse_server OPTIONS (user '${CLICKHOUSE_USER}', password '${CLICKHOUSE_PASSWORD}');
		EOSQL
    fi

    echo "Complete!"

    touch "${FDFILE}";
    echo "Mapped External Data."
fi