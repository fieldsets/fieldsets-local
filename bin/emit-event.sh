#!/usr/bin/env bash

#===
# emit-event.sh: Wrapper script to provide send an event to the event logger db from your local environment.
#
#===

set -eEa -o pipefail

#===
# Variables
#===
event_name=$1
pipeline_name=$2
status=$3
metadata=$4

#===
# Functions
#===
source /fieldsets-lib/shell/utils.sh
source /fieldsets-lib/shell/events.sh

##
# run: Run our command
##
run() {
    event_emitter "${event_name}" "${pipeline_name}" "${status}" "${metadata}"
}

#===
# Main
#===
run

trap traperr ERR
