#!/bin/bash
set -e

# This script is used by our fieldsets docker container. You can utilize it to custize any scripts you want to run on the container.

# Let's wait for our DBs to accept connections.
echo "Waiting for Postgres container...."
timeout 90s bash -c "until pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT; do printf '.'; sleep 5; done; printf '\n'"
echo "PostgreSQL is ready for connections."

echo "Waiting for Clickhouse container...."
timeout 90s bash -c "until curl --silent --output /dev/null http://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/ping; do printf '.'; sleep 5; done; printf '\n'"
echo "Clickhouse is ready for connections."

echo "Waiting for Mongo container...."
timeout 90s bash -c "until mongosh --host ${MONGO_HOST} --username ${MONGO_USER} --password ${MONGO_PASSWORD} --port ${MONGO_PORT} --authenticationDatabase admin --quiet --eval 'printjson(db.serverStatus().ok)'; do printf '.'; sleep 5; done; printf '\n'"
echo "Mongo is ready for connections."

export PGPASSWORD=${POSTGRES_PASSWORD}

# Here we check if we utilize external data sources and create our tables with foreign data wrappers if they exist.

FILE=/fieldsets/clickhouse.init
if [[ ! -f "$FILE" ]]; then
	# ClickHouse
	psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		IMPORT FOREIGN SCHEMA "$CLICKHOUSE_DB" LIMIT TO (sequences, records) 
        FROM SERVER clickhouse_server INTO "$POSTGRES_DB";

        ALTER TABLE $POSTGRES_DB.records
        ALTER value SET DATA TYPE field_value;

        ALTER TABLE $POSTGRES_DB.records
        ALTER fieldset_id SET DATA TYPE BIGINT;

        ALTER TABLE $POSTGRES_DB.records
        ALTER field_id SET DATA TYPE BIGINT;

        ALTER TABLE $POSTGRES_DB.records
        ALTER position SET DATA TYPE BIGINT;

        ALTER TABLE $POSTGRES_DB.sequences
        ALTER value SET DATA TYPE field_value;

        ALTER TABLE $POSTGRES_DB.sequences
        ALTER fieldset_id SET DATA TYPE BIGINT;

        ALTER TABLE $POSTGRES_DB.sequences
        ALTER field_id SET DATA TYPE BIGINT;

        ALTER TABLE $POSTGRES_DB.sequences
        ALTER position SET DATA TYPE BIGINT;
	EOSQL

    #clickhouse-client --host 127.0.0.1 --user $CLICKHOUSE_USER --password $CLICKHOUSE_PASSWORD --database $CLICKHOUSE_DB -n <<-EOSQL
#CREATE DICTIONARY IF NOT EXISTS $CLICKHOUSE_DB.fields
#(
#    source_id UInt8 INJECTIVE,
#	message_id UInt64 INJECTIVE,
#	message_ts DateTime,
#	message_text String,
#	user_id UInt64,
#	shared_message_id Nullable(UInt64),
#	quoted_message_id Nullable(UInt64),
#	reply_message_id Nullable(UInt64)
#)
#PRIMARY KEY source_id, message_id
#SOURCE(PostgreSQL(
#    NAME 'postgres_connection'
#    TABLE 'messages'
#	DB 'fieldsets'
#    SCHEMA 'social'
#))
#LAYOUT(COMPLEX_KEY_HASHED(PREALLOCATE 1))
#LIFETIME(MIN 3000 MAX 86400);
#EOSQL


	touch "$FILE"    
fi


FILE=/fieldsets/kafka.init
if [[ ! -f "$FILE" ]]; then
	# Kafka
	psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		CREATE FOREIGN TABLE IF NOT EXISTS $POSTGRES_DB.messages (
            id          BIGSERIAL NOT NULL,
            fieldset_id	BIGINT NOT NULL,
            message		JSONB OPTIONS (junk 'true'),
            meta		JSONB,
            ts			TIMESTAMP OPTIONS (json 'time_val'),
            parsed		BOOLEAN DEFAULT FALSE,
			"partition" INT OPTIONS (partition 'true'),
			"offset"    BIGINT OPTIONS (offset 'true')
		)
		SERVER kafka_server OPTIONS (format 'json', topic '${KAFKA_DATA_TOPIC}', batch_size '100', buffer_delay '100');
	EOSQL
	touch "$FILE"
fi

# Mongo
#FILE=/fieldsets/mongo.init
#if [[ ! -f "$FILE" ]]; then
#
#    psql -v ON_ERROR_STOP=1 --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#        CREATE FOREIGN TABLE IF NOT EXISTS $POSTGRES_DB.documents (
#            id          BIGSERIAL,
#		    fieldset_id	BIGINT NOT NULL,
#		    document	JSONB NULL,
#		    meta		JSONB NULL,
#		    ts			TIMESTAMP NULL DEFAULT NOW(),
#		    parsed		BOOLEAN DEFAULT FALSE
#	    ) 
#        SERVER mongo_server OPTIONS (database '$MONGO_DB', collection 'documents');
#	EOSQL
#
#	touch "$FILE"
#fi

# After everything has booted, run any custom scripts.
for f in /docker-entrypoint-initdb.d/*.sh; do 
    bash "$f"; 
done 

	

