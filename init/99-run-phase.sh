#!/usr/bin/env bash

#===
# 99-run-plugins.sh: Run any plugins or application run scripts
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
PRIORITY=99
last_checkpoint="/docker-entrypoint-init.d/99-run-phase.sh"

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# run: Run Phase is run at every startup
##
run() {
    log "Begin Run Phase...."
    local f
    for f in /fieldsets-plugins/*/; do
        if [ -f "${f}run.sh" ]; then
            log "Executing: ${f}run.sh"
            exec "${f}run.sh"
        fi
    done
    log "Run Phase Complete..."
}

#===
# Main
#===
trap traperr ERR

run

((PRIORITY+=1))
