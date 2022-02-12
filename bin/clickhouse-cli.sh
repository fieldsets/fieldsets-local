#!/bin/bash
set -e

# TODO: USE ENV VARIABLES FOR CONNECTION INFO

# This script provides you with the clickhouse terminal client with some timeout settings set so that calls to any external dbs using clickhouse's `remote()` function do not time out. 
cd ../
docker exec -it fieldsets-clickhouse clickhouse-client --host 0.0.0.0 --port 9000 --user fieldsets --password fieldsets --http_connection_timeout 0 --http_receive_timeout 0 --http_send_timeout 0 --connect_timeout 600 --receive_timeout 600 --send_timeout 600 --connections_with_failover_max_tries 5 --connect_timeout_with_failover_ms 6000 --multiquery
