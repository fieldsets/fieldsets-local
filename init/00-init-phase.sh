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
PRIORITY=00
last_checkpoint="/docker-entrypoint-init.d/00-init-phase.sh"

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# init: Init Phase is run only on the first startup.
##
init() {
    local init_phase_dir
    local init_phase_lock
    init_phase_dir="/fieldsets-data/phases/init/"
    init_phase_lock="${PRIORITY}-init-phase.complete"

    mkdir -p "${init_phase_dir}"
    if [[ ! -f "${init_phase_dir}${init_phase_lock}" ]]; then
        log "Begin Init Phase...."
        # Plugin Init Scripts should handle locking themselves.
        local f
        for f in /fieldsets-plugins/*/; do
            if [ -f "${f}init.sh" ]; then
                log "Executing: ${f}init.sh"
                exec "${f}init.sh"
            fi
        done
        log "Init Phase Complete."
        touch "${init_phase_dir}${init_phase_lock}"
    fi
}

#===
# Main
#===
trap traperr ERR

init

((PRIORITY+=1))
