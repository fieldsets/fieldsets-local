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

export PGPASSWORD=${FIELDSETS_DB_PASSWORD}
export DATA_PATH=/checkpoints/${ENVIRONMENT}/fieldsets-local/
export PRIORITY=0

#===
# Functions
#===
# Includes Methods traperr, wait_for_threads, log
source /usr/local/fieldsets/lib/bash/utils.sh

##
# start: Wrapper start up function. Executes everything in mapped init directory.
##
start() {
    if [[ ! -d "${DATA_PATH}" ]]; then
        mkdir -p ${DATA_PATH}
    fi

    # Let's wait for our DBs to accept connections.
    if [[ "${FIELDSETS_DB}" == "postgres" ]]; then
        log "Waiting for Postgres container...."
        timeout 90s bash -c "until pg_isready -h $FIELDSETS_DB_HOST -p $FIELDSETS_DB_PORT -U $FIELDSETS_DB_USER; do sleep 5; done; printf '\n'"
        log "PostgreSQL is ready for connections."
    fi

    if [[ "${FIELDSETS_STORE}" == "clickhouse" ]]; then
        log "Waiting for Clickhouse container...."
        timeout 90s bash -c "until curl --silent --output /dev/null http://${FIELDSETS_STORE_HOST}:${FIELDSETS_STORE_PORT}/ping; do sleep 5; done; printf '\n'"
        log "Clickhouse is ready for connections."
    fi

    SESSION_KEY_PATH=$(realpath ${SSH_KEY_PATH/#\~/$HOME})
    SESSION_KEY=$(realpath "${SESSION_KEY_PATH}/${FIELDSETS_SESSION_KEY:-fieldsets_rsa}")

    # Make sure a ssh key exists for our sessions.
    if [[ ! -f "${SESSION_KEY}" ]]; then
        ssh-keygen -b 2048 -t rsa -f $SESSION_KEY -q -N ""
        if [[ ! -f "${SESSION_KEY_PATH}/authorized_keys" ]]; then
            touch ${SESSION_KEY_PATH}/authorized_keys
        fi
        cat ${SESSION_KEY}.pub >> ${SESSION_KEY_PATH}/authorized_keys
    fi

    ssh-keygen -f "${SESSION_KEY_PATH}/known_hosts" -R "[${FIELDSETS_LOCAL_HOST}]:${SSH_PORT}"
    service ssh start

    #make sure our scripts are flagged at executable.
    chmod +x /docker-entrypoint-init.d/*.sh

    # Pass our entrypoint scipt directory managemnt over to powershell so we can create a persistant session
    log "Starting Pipeline"
    mkdir -p /data/logs/
    mkdir -p "/usr/local/fieldsets/data/logs/${ENVIRONMENT}/fieldsets-local/"
    LOG_PATH=$(realpath "/usr/local/fieldsets/data/logs/${ENVIRONMENT}/fieldsets-local/")

    if [[ ! -f "${LOG_PATH}/pipeline.log" ]]; then
        touch "${LOG_PATH}/pipeline.log"
    fi

    chmod +x /usr/local/fieldsets/bin/pipeline.sh
    nohup /usr/local/fieldsets/bin/pipeline.sh "-pipeline_pid $($pipeline_pid)">> ${LOG_PATH}/pipeline.log 2>&1 &

    log "Local Startup Complete."
}

#===
# Main
#===
trap traperr ERR

start

env >> /etc/environment

exec "$@"
