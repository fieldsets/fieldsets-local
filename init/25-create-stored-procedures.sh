#!/usr/bin/env bash

#===
# 25-create-stored-procedures.sh: Create our helpful procedures
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=20
export PGPASSWORD=${POSTGRES_PASSWORD}


#===
# Functions
#===
source /fieldsets-lib/bash/utils.sh

##
# init: execute our sql
##
init() {
    log "Creating procedures...."    
    local f
    for f in /fieldsets-sql/stored_procedures/*.sql; do
        log "Executing: ${f}"
        psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
    done

    log "Procedures created."
}

#===
# Main
#===
init

trap traperr ERR
