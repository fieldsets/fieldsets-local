#!/usr/bin/env bash

#===
# 30-enable-sync.sh: Wrapper script setting up sync insert triggers
# @envvar POSTGRES_TRIGGER_ROLE | String 
# @envvar POSTGRES_TRIGGER_ROLE_PASSWORD | String
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=30
export PGPASSWORD=${POSTGRES_PASSWORD}

pids=()

#===
# Functions
#===

##
# traperr: Better error handling
##
traperr() {
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
}

##
# wait_for_threads: Look at pids array and wait for all pids to complete.
# @depends pids
##
wait_for_threads() {
    # Our threads are running in the background. Lets wait for all of them to complete.
    for p in "${pids[@]}";
    do
        echo "Waiting for process id ${p}......"
        wait "${p}" 2>/dev/null
        echo "Thread with PID ${p} data migration has completed"
    done

    pids=()
}

##
# enable_sync: Add insert triggers and permissions
##
enable_sync() {
    echo "Creating Sync Triggers...."    
    # Install sync triggers. You must have write permissions on the target schema if schema is a FDW.
    if [[ "${ENABLE_DB_SYNC:-false}" == "true" ]]; then
        psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port ${POSTGRES_PORT} --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -c "CREATE SCHEMA IF NOT EXISTS ${DB_SYNC_TARGET_SCHEMA:-public};"

        local file_sql
        # Ensure our role has proper permissions for the target sync schema
        file_sql="--Set TRIGGER permissions on schema
        SET client_min_messages TO WARNING;
        GRANT USAGE ON SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_READER_ROLE};
        GRANT ALL PRIVILEGES ON SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_WRITER_ROLE};
        GRANT SELECT ON ALL TABLES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_READER_ROLE};
        GRANT SELECT ON ALL SEQUENCES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_READER_ROLE};
        GRANT EXECUTE ON ALL ROUTINES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_READER_ROLE};
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_WRITER_ROLE};
        GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_WRITER_ROLE};
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public} TO ${POSTGRES_WRITER_ROLE};"
        psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "$POSTGRES_PORT" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "${file_sql}"

        if [[ -z "${POSTGRES_TRIGGER_ROLE_PASSWORD}" ]]; then
            echo "Trigger Role Password Empty. Using postgresql user PW instad."
            POSTGRES_TRIGGER_ROLE_PASSWORD=${POSTGRES_PASSWORD}
        fi
        echo "Creating Trigger function...."
        local f
        for f in /fieldsets-sql/functions/sync/*.sql; do
            echo "Executing: ${f}"
            PGPASSWORD=${POSTGRES_TRIGGER_ROLE_PASSWORD} psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_TRIGGER_ROLE}" --dbname "${POSTGRES_DB}" -f "${f}"
        done

        for f in /fieldsets-sql/triggers/sync/*.sql; do
            echo "Executing: ${f}"
            file_sql=$(cat "${f}")
            PGPASSWORD=${POSTGRES_TRIGGER_ROLE_PASSWORD} psql -b -e -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port ${POSTGRES_PORT} --username ${POSTGRES_TRIGGER_ROLE} --dbname $POSTGRES_DB <<-EOSQL
				\set SOURCE_SCHEMA ${DB_SYNC_SOURCE_SCHEMA:-fieldsets}
				\set TARGET_SCHEMA ${DB_SYNC_TARGET_SCHEMA:-public}
				SET search_path TO ${DB_SYNC_SOURCE_SCHEMA:-fieldsets};
				${file_sql}
			EOSQL
        done

    else 
        psql -v ON_ERROR_STOP=1 --host ${POSTGRES_HOST} --port ${POSTGRES_PORT} --username ${POSTGRES_USER} --dbname ${POSTGRES_DB} -f "/fieldsets-sql/triggers/sync/00_drop_triggers.sql"
    fi

    echo "Sync Triggers created."
}

#===
# Main
#===
enable_sync

trap '' 2 3
trap traperr ERR
