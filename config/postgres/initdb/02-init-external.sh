#!/bin/bash
set -e

# Instantiate our Foreign Data Wrappers
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"  <<-EOSQL
SET search_path TO 'public';
CREATE EXTENSION kafka_fdw;

CREATE SERVER kafka_server
FOREIGN DATA WRAPPER kafka_fdw
OPTIONS (brokers '$KAFKA_HOST:$KAFKA_PORT');

CREATE USER MAPPING FOR CURRENT_USER SERVER kafka_server;

CREATE EXTENSION clickhouse_fdw;

CREATE SERVER clickhouse_server 
FOREIGN DATA WRAPPER clickhouse_fdw 
OPTIONS(dbname '$CLICKHOUSE_DB', host '$CLICKHOUSE_HOST', port '9000', driver 'binary');

CREATE USER MAPPING FOR CURRENT_USER SERVER clickhouse_server OPTIONS (user '$CLICKHOUSE_USER', password '$CLICKHOUSE_PASSWORD');

CREATE EXTENSION mongo_fdw;

CREATE SERVER mongo_server 
FOREIGN DATA WRAPPER mongo_fdw
OPTIONS (address '$MONGO_HOST', port '$MONGO_PORT');

CREATE USER MAPPING FOR CURRENT_USER SERVER mongo_server OPTIONS (username '$MONGO_USER', password '$MONGO_PASSWORD');

EOSQL
