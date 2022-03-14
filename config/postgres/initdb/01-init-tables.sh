#!/bin/bash
set -e

# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	/**
	 * Sets can be thought of as labeled groups.
	 * They defined what data is what and which fields belong together.
	 * A set can exist without being used in a fieldset. This is useful for tagging individual fields alongside their fieldset grouping.
	 */
	CREATE TABLE IF NOT EXISTS fieldsets.sets (
		id         	BIGSERIAL PRIMARY KEY,
		token     	VARCHAR(255) NOT NULL UNIQUE,
		label      	TEXT NULL,
		description TEXT NULL,
		parent     	BIGINT NULL DEFAULT 0,
		meta  		JSONB NULL,
		FOREIGN KEY (parent) REFERENCES fieldsets.sets(id)
	);

	CREATE TABLE IF NOT EXISTS fieldsets.fields (
		id         			BIGSERIAL PRIMARY KEY,
		token     			VARCHAR(255) NOT NULL UNIQUE,
		label      			TEXT NULL,
		description 		TEXT NULL,
		primary_set			BIGINT NULL,
		type				field_type NULL,
		default_value 		field_value NULL,
		default_position	BIGINT NULL DEFAULT 0,
		parent     			BIGINT NULL DEFAULT 0,
		meta  				JSONB NULL,
		FOREIGN KEY (parent) REFERENCES fieldsets.fields(id),
		FOREIGN KEY (primary_set) REFERENCES fieldsets.sets(id)
	);


    /**
     * This table is a row oriented lookup table for each set's field list.
     *
     **/
	CREATE TABLE IF NOT EXISTS fieldsets.set_members (
		set_id 		BIGINT,
		field_id	BIGINT,
		FOREIGN KEY (field_id) REFERENCES fieldsets.fields(id),
		FOREIGN KEY (set_id) REFERENCES fieldsets.sets(id)
	);
	CREATE UNIQUE INDEX IF NOT EXISTS set_members_idx ON fieldsets.set_members (set_id,field_id);

	/**
	 * FieldSets allow us to store sets and field members across our various data stores.
	 */
	CREATE TABLE IF NOT EXISTS fieldsets.fieldsets (
		id         	BIGSERIAL PRIMARY KEY,
		token		VARCHAR(255) NOT NULL UNIQUE,
		type		VARCHAR(255) NULL,
		store		store_type NULL DEFAULT 'record',
		source		VARCHAR(255) NULL,
		set_id 		BIGINT NULL DEFAULT 0,
		parent     	BIGINT NULL DEFAULT 0,
		meta  		JSONB NULL,
		FOREIGN KEY (parent) REFERENCES fieldsets.fieldsets(id),
		FOREIGN KEY (set_id) REFERENCES fieldsets.sets(id)
	);
	CREATE UNIQUE INDEX IF NOT EXISTS fieldsets_token_idx ON fieldsets.fieldsets ((lower(token)));

	CREATE TABLE IF NOT EXISTS fieldsets.connections (
		id						BIGSERIAL PRIMARY KEY,
		distance				DECIMAL NULL DEFAULT 0,
		weight					DECIMAL NULL DEFAULT 1,
		fieldset_id				BIGINT NOT NULL,
		connected_fieldset_id	BIGINT NOT NULL,
		meta					JSONB NULL,
		ts						TIMESTAMP NULL DEFAULT NOW(),
		FOREIGN KEY (connected_fieldset_id) REFERENCES fieldsets.fieldsets(id),
		FOREIGN KEY (fieldset_id) REFERENCES fieldsets.fieldsets(id)
	);

    /**
     * Profiles are your traditional relational row based data store.
     * Profiles types defined in the fieldset table will have data points stored here in as a attributes document.
     * For each entry of profile type in the fieldsets table, a corresponding materialized view will be created from the attributes document with columns fully expanded for faster relational searches.
     * Each of these views can be loaded as a dictionary in Clickhouse to improve data joins there.
     */
	CREATE TABLE IF NOT EXISTS fieldsets.profiles (
		id			BIGSERIAL,
		fieldset_id	BIGINT NOT NULL,
		label		TEXT NULL,
		description	TEXT NULL,
		parent		BIGINT NULL DEFAULT 0,
		attributes	JSONB NULL,
		meta       	JSONB NULL,
		parsed		BOOLEAN DEFAULT FALSE,
		FOREIGN KEY (fieldset_id) REFERENCES fieldsets.fieldsets(id)
	) PARTITION BY LIST(fieldset_id);
	CREATE INDEX profiles_attributes_idx ON fieldsets.profiles USING GIN (attributes);
	
	/**
	 * Insert triggers into fieldsets table will build new partitions using the fieldset token.
	 * Using the same insert trigger will also create a materialized view with the attributes expanded into columns. 
	 */
	CREATE TABLE IF NOT EXISTS fieldsets.profiles_default PARTITION OF fieldsets.profiles DEFAULT;

	CREATE TABLE IF NOT EXISTS fieldsets.documents (
        id          BIGSERIAL,
		fieldset_id	BIGINT NOT NULL,
		document	JSONB NULL,
		meta		JSONB NULL,
		ts			TIMESTAMP NULL DEFAULT NOW(),
		parsed		BOOLEAN DEFAULT FALSE,
		FOREIGN KEY (fieldset_id) REFERENCES fieldsets.fieldsets(id)
	) PARTITION BY LIST(fieldset_id);
	CREATE INDEX documents_doc_idx ON fieldsets.documents USING GIN (document);
	
    /**
	 * Insert triggers into fieldsets table will build new partitions using the fieldset token.
	 * Using the same insert trigger will also create a materialized view with the attributes expanded into columns. 
	 */
	CREATE TABLE IF NOT EXISTS fieldsets.documents_default PARTITION OF fieldsets.documents DEFAULT;
EOSQL