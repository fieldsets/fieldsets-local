#!/bin/bash

# This script will set up foreign data servers on the target postgresql instance.
# If the target postgres DB is on AWS, make sure it is not a read replica and that the account used to authenticate has appropriate permissions.
# Conversly, make sure that VBDB_HOST and FIELDSETS_PHI are read replicas as writes to AWS instances should be done through the production pipeline.
# This script needs to be run after the DB is up and running. Utilizing fieldsets-local, you can add this script to the init directory when needed.

set -e

export PRIORITY=10
export PGPASSWORD=${POSTGRES_PASSWORD}
FDFILE="/data/checkpoints/${PRIORITY}-pg-foreign-data-import.complete"

if [[ ! -f "${FDFILE}" ]]; then
    echo "Setting up external data sources...."
    # If we are within AWS network, we can access our DBs directly.
    if [[ -z "${SSH_HOST:-}" ]]; then
        echo "Setting up foreign data servers..."
        EVENTS_FDW_HOST=${EVENTS_HOST}
        EVENTS_FDW_PORT=${EVENTS_PORT}
    # Otherwise utilize a jump server
    else
        echo "Setting up tunneled foreign data servers..."
        EVENTS_FDW_HOST=${EVENTS_HOST}
        EVENTS_FDW_PORT=${EVENTS_TUNNEL_PORT}
        if [[ "${EVENTS_HOST}" == "${POSTGRES_HOST}" ]]; then
            EVENTS_FDW_PORT=${EVENTS_PORT}
        fi
    fi

    # Wait for Foreign Servers
    echo "Waiting for foreign servers"

    if [[ -n "${EVENTS_PASSWORD:-}" ]] ; then
        timeout 120s bash -c "until pg_isready -h $EVENTS_FDW_HOST -p $EVENTS_FDW_PORT; do printf '.'; sleep 5; done; printf '\n'"
    fi

    # Only map our pipeline schema if we are not working on the local docker environment.
    if [[ -n "${EVENTS_PASSWORD:-}" ]]; then
        echo "Creating Foreign Data Server for ${EVENTS_FDW_HOST} with user $EVENTS_USER"
        psql -v ON_ERROR_STOP=0 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            -- Declare Foreign Servers.
            CREATE SERVER IF NOT EXISTS events_server
            FOREIGN DATA WRAPPER postgres_fdw
            OPTIONS (host '$EVENTS_FDW_HOST', port '$EVENTS_FDW_PORT', dbname 'fieldsets', fetch_size '100000', batch_size '100');
    
            CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER events_server OPTIONS (user '$EVENTS_USER', password '$EVENTS_PASSWORD');
            CREATE USER MAPPING IF NOT EXISTS FOR ${POSTGRES_TRIGGER_ROLE} SERVER events_server OPTIONS (user '$EVENTS_USER', password '$EVENTS_PASSWORD');
		EOSQL
    fi

    # Postgres
    # Always allow external sources to be added after initialization as these should be read only.
    echo "Importing remote postgres data schemas......"


    if [[ -n "${EVENTS_PASSWORD:-}" ]] && [[ "${EVENTS_HOST}" != "${POSTGRES_HOST}" ]]; then
        psql -v ON_ERROR_STOP=0 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            IMPORT FOREIGN SCHEMA "pipeline" LIMIT TO (events, containers) FROM SERVER events_server INTO pipeline;
		EOSQL
    fi

    if [[ "${CLICKHOUSE_ENABLED:-false}" == "true" ]]; then
        psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE EXTENSION IF NOT EXISTS clickhouse_fdw;
            CREATE SERVER IF NOT EXISTS clickhouse_server 
                FOREIGN DATA WRAPPER clickhouse_fdw
                OPTIONS(dbname 'results', host '${CLICKHOUSE_HOST}', port '${CLICKHOUSE_PORT}');
            
            CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER clickhouse_server OPTIONS (user '${CLICKHOUSE_USER}', password '${CLICKHOUSE_PASSWORD}');
            CREATE USER MAPPING IF NOT EXISTS FOR ${POSTGRES_TRIGGER_ROLE} SERVER clickhouse_server OPTIONS (user '${CLICKHOUSE_USER}', password '${CLICKHOUSE_PASSWORD}');
		EOSQL
    fi

    echo "Complete!"

    touch "${FDFILE}";
    echo "Mapped External Data."
fi