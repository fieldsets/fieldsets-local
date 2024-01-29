#!/usr/bin/env bash
set -e 

# Specify a SSH host to utilize a jump server
if [[ -n "${SSH_HOST}" ]]; then
    echo "Jump Server ${SSH_HOST} is defined. Setting up tunnels."

    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        eval "$(ssh-agent -s)"
        ssh-add /root/.ssh/id_rsa
    fi

    AUTOSSH_POLL=600
    AUTOSSH_PORT=20000
    AUTOSSH_GATETIME=30
    AUTOSSH_DEBUG=yes
    export AUTOSSH_POLL AUTOSSH_DEBUG AUTOSSH_PATH AUTOSSH_GATETIME AUTOSSH_PORT

    AUTOSSH_LOG_PATH=/data/logs/tunnels/
    if [[ ! -d "${AUTOSSH_LOG_PATH}" ]]; then
        mkdir -p "${AUTOSSH_LOG_PATH}"
    fi

    if [[ -n "${EVENTS_HOST}" ]] && [[ "${EVENTS_HOST}" != "${POSTGRES_HOST}" ]]; then
        echo "Setting up SSH tunnel....."
        AUTOSSH_LOGFILE=${AUTOSSH_LOG_PATH}${EVENTS_HOST}.log
        export AUTOSSH_LOGFILE
        autossh -2 -fN -M 20000 -o ServerAliveInterval=60 -o StrictHostKeyChecking=no -4 -L $FIELDSETS_LOCAL_HOST:$EVENTS_TUNNEL_PORT:$EVENTS_HOST:$EVENTS_PORT $SSH_USER@$SSH_HOST -p $SSH_PORT -o ServerAliveInterval=60 -o StrictHostKeyChecking=no
    fi
    echo "Tunnels ready."

    # Make sure our tunnels are connected.
    echo "Waiting for remote Postgres tunnels...."

    if [[ -n "${EVENTS_HOST}" ]] && [[ "${EVENTS_HOST}" != "${POSTGRES_HOST}" ]]; then
        timeout 60s bash -c "until pg_isready -h $FIELDSETS_LOCAL_HOST -p $EVENTS_TUNNEL_PORT -U $EVENTS_USER; do printf '.'; sleep 5; done; printf '\n'"
    fi

    echo "Tunnels are ready for connections."
fi
