#!/bin/bash

# Boilerplate shell script for fetching whatever you need.
set -e

# After boot, import the CH schema into Postgres 
PGPASSWORD=${POSTGRES_PASSWORD} psql --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	IMPORT FOREIGN SCHEMA "$CLICKHOUSE_DB" FROM SERVER clickhouse_server INTO "clickhouse";
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
