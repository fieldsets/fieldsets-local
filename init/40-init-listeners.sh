#!/usr/bin/env bash

#===
# 40-init-listeners.sh: Create our helpful procedures
#
#===

set -eEa -o pipefail

#===
# Variables
#===

export PRIORITY=40
export PGPASSWORD=${POSTGRES_PASSWORD}


#===
# Functions
#===
source /fieldsets-lib/shell/utils.sh
source /fieldsets-lib/shell/events.sh

##
# init: execute our sql
##
init() {
    psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --port "${POSTGRES_PORT}" --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
        CALL cron.create_event_listener('local');
	EOSQL
}

#===
# Main
#===
init

trap 'trap_failed_event $? "{}"' ERR


