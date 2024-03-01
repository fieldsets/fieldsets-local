#!/usr/bin/env bash

#===
# 11-create-tables.sh: Create our Fieldset Store Type Tables
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=11
export PGPASSWORD=${POSTGRES_PASSWORD}

#===
# Functions
#===
source /fieldsets-lib/bash/utils.sh

##
# init: execute our sql
##
init() {
    log "Creating tables...."
    local f
    if [[ "${ENABLE_STORE:-false}" == "true" ]]; then
        for f in /fieldsets-sql/tables/${FIELDSETS_STORE:-clickhouse}/*.sql; do
            log "Executing: ${f}"
            case ${FIELDSETS_STORE:-clickhouse} in
                clickhouse)
                    clickhouse-client --host ${CLICKHOUSE_HOST} --user ${CLICKHOUSE_USER} --password ${CLICKHOUSE_PASSWORD} --database ${CLICKHOUSE_DB} -nm --queries-file ${f}
                    ;;
                *)
                    clickhouse-client --host ${CLICKHOUSE_HOST} --user ${CLICKHOUSE_USER} --password ${CLICKHOUSE_PASSWORD} --database ${CLICKHOUSE_DB} -nm --queries-file ${f}
                    ;;
            esac
        done
    fi

    for f in /fieldsets-sql/tables/${FIELDSETS_DB:-postgres}/*.sql; do
        log "Executing: ${f}"
        case ${FIELDSETS_DB:-postgres} in
            postgres)
                psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
                ;;
            *)
                psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
                ;;
        esac
    done

    log "Tables created."
}

#===
# Main
#===
init

trap '' 2 3
trap traperr ERR
