#!/bin/bash
set -e

###
# Execute arbitrary SQL here for clickhouse initialization.
# This is the spot where you want to manage creating users, defining custom functions, tables views and anything else 
# that would need to be defined before the core fieldsets data architecture is built.
###
clickhouse-client --host 127.0.0.1 --user $CLICKHOUSE_USER --password $CLICKHOUSE_PASSWORD --database system -n <<-EOSQL
    CREATE DATABASE IF NOT EXISTS $CLICKHOUSE_DB;

    CREATE DATABASE IF NOT EXISTS postgres
    ENGINE = PostgreSQL('$POSTGRES_HOST:$POSTGRES_PORT', '$POSTGRES_DB', '$POSTGRES_USER', '$POSTGRES_PASSWORD', '$POSTGRES_DB', 1);
EOSQL
