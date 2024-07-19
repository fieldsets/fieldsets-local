#!/usr/bin/env bash

#===
# 01-install-libs.sh: Install any libraries
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=5

#===
# Functions
#===

source /usr/local/fieldsets/lib/bash/utils.sh

##
# init: execute our sql
##
init() {
    log "Installing libraries & modules...."
    pwsh -Command "& {Install-Module -Name ImportExcel -Force -AllowClobber}"
    log "Libraries installed."
}

#===
# Main
#===
init

trap '' 2 3
trap traperr ERR
