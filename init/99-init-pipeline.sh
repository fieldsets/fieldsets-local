#!/bin/bash
set -e

export PRIORITY=99
export PGPASSWORD=${POSTGRES_PASSWORD}

# If user has defined an init script volume, iterate through it.

cd "${0%/*}";

start() {
	if [[ -d "/pipeline-init/" ]]; then 
		#make sure our scripts are flagged at executable.
		chmod +x /pipeline-init/*.sh
		# After everything has booted, run any custom scripts.
		for f in /pipeline-init/*.sh; do
			bash "$f"; 
		done 

		echo "Pipeline Execution Complete."
	fi
}

start
