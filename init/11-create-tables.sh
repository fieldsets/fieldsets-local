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
source /fieldsets-lib/shell/utils.sh

##
# init: execute our sql
##
init() {
    log "Creating tables...."    
    local f
	for f in /fieldsets-sql/tables/clickhouse/*.sql; do
        log "Executing: ${f}"
        clickhouse-client --host ${CLICKHOUSE_HOST} --user ${CLICKHOUSE_USER} --password ${CLICKHOUSE_PASSWORD} --database ${CLICKHOUSE_DB} -nm --queries-file ${f}
    done

    for f in /fieldsets-sql/tables/postgres/*.sql; do
        log "Executing: ${f}"
        psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
    done

    log "Tables created."
}

#===
# Main
#===
init

trap '' 2 3
trap traperr ERR
