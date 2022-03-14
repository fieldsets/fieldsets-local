#!/bin/bash
set -e

# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE SCHEMA fieldsets;
	CREATE SCHEMA messages;
	CREATE SCHEMA collections;
	CREATE SCHEMA texts;

	CREATE TYPE store_type AS ENUM ('profile', 'record', 'connection', 'document', 'message', 'sequence', 'text', 'none');
	CREATE TYPE field_type AS ENUM ('string', 'number', 'decimal', 'object', 'list', 'bool', 'date', 'ts', 'function');
	CREATE TYPE field_value AS (
		"string"		TEXT,
		"number"		BIGINT,
		"decimal"		DECIMAL,
		"object"		JSONB,
		"list" 			TEXT[],
		"bool" 			BOOLEAN,
		"date" 			DATE,
		"ts"			TIMESTAMP,
		"function"		JSONB
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
