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
PRIORITY=1
last_checkpoint="/docker-entrypoint-init.d/01-config-phase.sh"

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# run: Config Phase is run at beginning of every startup
##
run() {
    log "Begin Run Phase...."
    local f
    for f in /fieldsets-plugins/*/; do
        if [ -f "${f}config.sh" ]; then
            log "Executing: ${f}config.sh"
            exec "${f}config.sh"
        fi
    done
    log "Config Phase Complete..."
}

#===
# Main
#===
trap traperr ERR

run

((PRIORITY+=1))
