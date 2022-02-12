#!/bin/bash
set -e

# This script is used by our fieldsets docker container. You can utilize it to custize any scripts you want to run on the container.

for f in /docker-entrypoint-initdb.d/*.sh; do 
    bash "$f"; 
done 

