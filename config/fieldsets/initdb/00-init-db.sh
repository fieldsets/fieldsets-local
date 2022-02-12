#!/bin/bash

set -e

export PGPASSWORD=${POSTGRES_PASSWORD}

# Here we check if we utilize external data sources and create our tables with foreign data wrappers if they exist.

# ClickHouse
psql --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    IMPORT FOREIGN SCHEMA "$CLICKHOUSE_DB" FROM SERVER clickhouse_server INTO "clickhouse";
EOSQL

# Kafka
psql --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	SET search_path TO 'messages';
	CREATE FOREIGN TABLE messages.kafka_${KAFKA_DATA_TOPIC} (
    	part int OPTIONS (partition 'true'),
    	offs bigint OPTIONS (offset 'true'),
    	message JSONB
	)
	SERVER kafka_server OPTIONS (format 'json', topic '${KAFKA_DATA_TOPIC}', batch_size '100', buffer_delay '100');
EOSQL


