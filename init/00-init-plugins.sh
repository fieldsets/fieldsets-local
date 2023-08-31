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
last_checkpoint="/docker-entrypoint-init.d/00-init-plugins.sh"

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# init: Initialize any plugins
##
init() {
    log "Initializing Plugins...."
    local f
    for f in /fieldsets-plugins/*/; do
        if [ -f "${f}init.sh" ]; then
            log "Executing: ${f}init.sh"
            exec "${f}init.sh"
        fi
    done

    log "Plugins Initialized."
}

#===
# Main
#===
trap traperr ERR

init

((PRIORITY+=1))
