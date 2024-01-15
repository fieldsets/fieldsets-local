#!/usr/bin/env bash

#===
# 30-create-triggers.sh: Create our triggers
# See shell coding standards for details of formatting.
# https://github.com/fieldsets/fieldsets/blob/main/docs/developer/coding-standards/shell.md
#
# @envvar VERSION | String 
# @envvar ENVIRONMENT | String
#
#===

set -eEa -o pipefail

#===
# Variables
#===
export PGPASSWORD=${POSTGRES_PASSWORD} 
PRIORITY=30
last_checkpoint="/docker-entrypoint-init.d/30-create-triggers.sh"

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# init: execute our sql
##
init() {
    log "Creating triggers...."    
    local f
    for f in /fieldsets-sql/triggers/*.sql; do
        log "Executing: ${f}"
        psql -v ON_ERROR_STOP=0 --host "${POSTGRES_HOST}" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -f "${f}"
    done

    log "Triggers created."
}

#===
# Main
#===
trap traperr ERR

init

((PRIORITY+=1))

