#!/usr/bin/env bash

#===
# 00-init.sh: Wrapper script for your docker container
# See shell coding standards for details of formatting. 
# https://github.com/Fieldsets/fieldsets-pipeline/blob/main/docs/developer/coding-standards/shell.md
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
export DATA_PATH=/data/checkpoints/${ENVIRONMENT}/fieldsets-local/
export PRIORITY=0

#===
# Functions
#===
# Includes Methods traperr, wait_for_threads, log
source /fieldsets-lib/shell/utils.sh
source /fieldsets-lib/shell/events.sh

##
# start: Wrapper start up function. Executes everything in mapped init directory. 
##
start() {
	if [[ ! -d "${DATA_PATH}" ]]; then
        mkdir -p ${DATA_PATH}
    fi

	# Let's wait for our DBs to accept connections.
	log "Waiting for Postgres container...."
	timeout 90s bash -c "until pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER; do printf '.'; sleep 5; done; printf '\n'"
	log "PostgreSQL is ready for connections."

	if [[ "${CLICKHOUSE_ENABLED:-false}" == "true" ]]; then
		log "Waiting for Clickhouse container...."
		timeout 90s bash -c "until curl --silent --output /dev/null http://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/ping; do printf '.'; sleep 5; done; printf '\n'"
		log "Clickhouse is ready for connections."
	fi

	#make sure our scripts are flagged at executable.
	chmod +x /docker-entrypoint-init.d/*.sh
	# After everything has booted, run any custom scripts.
	for f in /docker-entrypoint-init.d/*.sh; do
		bash "$f"; 
	done 

	log "Local Startup Complete."
	event_emitter 'fieldsets-local-container-init' 'local' 'pending' '{}' 
}

#===
# Main
#===
trap traperr ERR

start

env >> /etc/environment

exec "$@"
