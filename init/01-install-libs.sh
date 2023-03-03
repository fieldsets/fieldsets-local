#!/usr/bin/env bash

#===
# 01-install-libs.sh: Install any libraries
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=1

#===
# Functions
#===

source /fieldsets-lib/shell/utils.sh

##
# init: execute our sql
##
init() {
    log "Installing libraries...."    
    
    log "Libraries installed."
}

#===
# Main
#===
init

trap '' 2 3
trap traperr ERR
