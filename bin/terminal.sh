#!/bin/bash
set -e

SERVER=$1

# This script provides you with the the cli terminal client
docker exec -it $SERVER /bin/bash