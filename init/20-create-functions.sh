#!/usr/bin/env bash

#===
# 20-create-functions.sh: Create our helpful functions
# @envvar POSTGRES_TRIGGER_ROLE | String 
# @envvar POSTGRES_TRIGGER_ROLE_PASSWORD | String
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY="20"
export PGPASSWORD=${POSTGRES_PASSWORD}

#===
# Functions
#===
source /usr/local/fieldsets/lib/bash/utils.sh

##
# init: execute our sql
##
init() {
    log "Creating functions...."
    local f
    for f in /usr/local/fieldsets/sql/functions/*.sql; do
        log "Executing: ${f}"
        psql -v ON_ERROR_STOP=1 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
    done

    log "Functions created."
}

#===
# Main
#===
init

trap '' 2 3
trap traperr ERR
