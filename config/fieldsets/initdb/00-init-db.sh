#!/bin/bash

set -e

export PGPASSWORD=${POSTGRES_PASSWORD}

# Here we check if we utilize external data sources and create our tables with foreign data wrappers if they exist.

# Let's wait for our DBs to accept connections.
echo "Waiting for Postgres container...."
timeout 90s bash -c "until pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT; do printf '.'; sleep 5; done; printf '\n'"
echo "PostgreSQL is ready for connections."

echo "Waiting for Clickhouse container...."
timeout 90s bash -c "until curl --silent --output /dev/null http://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/ping; do printf '.'; sleep 5; done; printf '\n'"
echo "Clickhouse is ready for connections."


# ClickHouse
psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    IMPORT FOREIGN SCHEMA "$CLICKHOUSE_DB" FROM SERVER clickhouse_server INTO "clickhouse";
EOSQL

# Kafka
psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	SET search_path TO 'messages';
	CREATE FOREIGN TABLE messages.kafka_${KAFKA_DATA_TOPIC} (
    	part int OPTIONS (partition 'true'),
    	offs bigint OPTIONS (offset 'true'),
    	message JSONB
	)
	SERVER kafka_server OPTIONS (format 'json', topic '${KAFKA_DATA_TOPIC}', batch_size '100', buffer_delay '100');
EOSQL


