#!/bin/bash
set -e

# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_USER" <<-EOSQL
	CREATE SCHEMA $POSTGRES_DB;
	CREATE SCHEMA clickhouse;
	CREATE SCHEMA messages;
	CREATE SCHEMA documents;

	CREATE TYPE store_type AS ENUM ('profile', 'record', 'connection', 'document', 'message', 'sequence');
	CREATE TYPE field_type AS ENUM ('string', 'number', 'object', 'list', 'bool', 'date', 'ts');
	CREATE TYPE field_value AS (
		"string"		TEXT,
		"number"		BIGINT,
		"decimal"		DECIMAL,
		"object"		JSONB,
		"list" 			TEXT[],
		"bool" 			BOOLEAN,
		"date" 			DATE,
		"ts"			TIMESTAMP
	);

	/**
	 * This table is created to track setup of the fieldset frameworks
	 * This is the place to look for working configurations if any system upgrade breaks the framework.
	 * This data can be sensitive per server and should be separate from the fieldsets schema.
	 * All config values are store as strings.
	 */
	CREATE TABLE public.config (
		id         	BIGSERIAL PRIMARY KEY,
		token     	VARCHAR(255) NOT NULL UNIQUE,
		description TEXT NULL,
		value      	TEXT NULL,
		meta  		JSONB NULL
	);
EOSQL
