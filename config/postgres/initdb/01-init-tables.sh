#!/bin/bash
set -e

# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	/**
	 * Sets can be thought of as labeled groups.
	 * They defined what data is what and which fields belong together.
	 * A set can exist without being used in a fieldset. This is useful for tagging individual fields alongside their fieldset grouping.
	 */
	CREATE TABLE $POSTGRES_DB.sets (
		id         	BIGSERIAL PRIMARY KEY,
		token     	VARCHAR(255) NOT NULL UNIQUE,
		label      	TEXT NULL,
		description TEXT NULL,
		parent     	BIGINT NULL DEFAULT 0,
		meta  		JSONB NULL,
		FOREIGN KEY (parent) REFERENCES $POSTGRES_DB.sets(id)
	);

	CREATE TABLE $POSTGRES_DB.fields (
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
		FOREIGN KEY (parent) REFERENCES $POSTGRES_DB.fields(id),
		FOREIGN KEY (primary_set) REFERENCES $POSTGRES_DB.sets(id)
	);


    /**
     * This table is a row oriented lookup table for each set's field list.
     *
     **/
	CREATE TABLE $POSTGRES_DB.groups (
		id			BIGSERIAL PRIMARY KEY,
		set_id 		BIGINT,
		field_id	BIGINT,
		FOREIGN KEY (field_id) REFERENCES $POSTGRES_DB.fields(id),
		FOREIGN KEY (set_id) REFERENCES $POSTGRES_DB.sets(id)
	);
	CREATE UNIQUE INDEX fieldset_groups_idx ON $POSTGRES_DB.groups (set_id,field_id);

	CREATE TABLE $POSTGRES_DB.fieldsets (
		id         	BIGSERIAL PRIMARY KEY,
		token		VARCHAR(255) NOT NULL UNIQUE,
		type		VARCHAR(255) NULL,
		store		store_type NULL DEFAULT 'record',
		set_id 		BIGINT NULL DEFAULT 0,
		parent     	BIGINT NULL DEFAULT 0,
		meta  		JSONB NULL,
		FOREIGN KEY (parent) REFERENCES $POSTGRES_DB.fieldsets(id),
		FOREIGN KEY (set_id) REFERENCES $POSTGRES_DB.sets(id)
	);
	CREATE UNIQUE INDEX fieldsets_token_idx ON $POSTGRES_DB.fieldsets ((lower(token)));

	CREATE TABLE $POSTGRES_DB.connections (
		id						BIGSERIAL PRIMARY KEY,
		distance				DECIMAL NULL DEFAULT 0,
		weight					DECIMAL NULL DEFAULT 1,
		fieldset_id				BIGINT NOT NULL,
		connected_fieldset_id	BIGINT NOT NULL,
		meta					JSONB NULL,
		ts						TIMESTAMP NULL DEFAULT NOW(),
		FOREIGN KEY (connected_fieldset_id) REFERENCES $POSTGRES_DB.fieldsets(id),
		FOREIGN KEY (fieldset_id) REFERENCES $POSTGRES_DB.fieldsets(id)
	);

    /**
     * Profiles are your traditional relational row based data store.
     * Profiles types defined in the fieldset table will have data points stored here in as a attributes document.
     * For each entry of profile type in the fieldsets table, a corresponding materialized view will be created from the attributes document with columns fully expanded for faster relational searches.
     * Each of these views can be loaded as a dictionary in Clickhouse to improve data joins there.
     */
	CREATE TABLE $POSTGRES_DB.profiles (
		id			BIGSERIAL,
		fieldset_id	BIGINT NOT NULL,
		label		TEXT NULL,
		description	TEXT NULL,
		parent		BIGINT NULL DEFAULT 0,
		attributes	JSONB NULL,
		meta       	JSONB NULL,
		parsed		BOOLEAN DEFAULT FALSE,
		FOREIGN KEY (fieldset_id) REFERENCES $POSTGRES_DB.fieldsets(id)
	) PARTITION BY LIST(fieldset_id);
	/**
	 * Insert triggers into fieldsets table will build new partitions using the fieldset token.
	 * Using the same insert trigger will also create a materialized view with the attributes expanded into columns. 
	 */
	CREATE TABLE $POSTGRES_DB.profiles_default PARTITION OF $POSTGRES_DB.profiles DEFAULT;


    /**
	 * Documents are your standard NOSQL document data store such as MongoDB or CouchDB
	 * Schema should be stored in the parent fieldset meta data using the "schema" key.
	 * As new documents are added into this table, triggers will process new rows and utilizing the schema create corresponding entries in either the record, sequence or profile tables.
	 */
    CREATE TABLE $POSTGRES_DB.documents (
        id          BIGSERIAL,
		fieldset_id	BIGINT NOT NULL,
		document	JSONB NULL,
		meta		JSONB NULL,
		ts			TIMESTAMP NULL DEFAULT NOW(),
		parsed		BOOLEAN DEFAULT FALSE,
		FOREIGN KEY (fieldset_id) REFERENCES $POSTGRES_DB.fieldsets(id)
	) PARTITION BY RANGE(ts);
	/**
	 * Insert triggers will check the year and create a n
	 */
	CREATE TABLE $POSTGRES_DB.documents_2025 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2025-01-01'::TIMESTAMP) TO ('2025-12-31'::TIMESTAMP); 
	CREATE TABLE $POSTGRES_DB.documents_2024 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2024-01-01'::TIMESTAMP) TO ('2024-12-31'::TIMESTAMP); 
	CREATE TABLE $POSTGRES_DB.documents_2023 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2023-01-01'::TIMESTAMP) TO ('2023-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2022 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2022-01-01'::TIMESTAMP) TO ('2022-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2021 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2021-01-01'::TIMESTAMP) TO ('2021-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2020 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2020-01-01'::TIMESTAMP) TO ('2020-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2019 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2019-01-01'::TIMESTAMP) TO ('2019-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2018 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2018-01-01'::TIMESTAMP) TO ('2018-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2017 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2017-01-01'::TIMESTAMP) TO ('2017-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2016 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2016-01-01'::TIMESTAMP) TO ('2016-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_2015 PARTITION OF $POSTGRES_DB.documents FOR VALUES FROM ('2015-01-01'::TIMESTAMP) TO ('2015-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.documents_archive PARTITION OF $POSTGRES_DB.documents DEFAULT;

	/**
	 * The Messages table can also be used as a log table. It represents data stores that serve as message queues. 
	 * Whether it be a message broker or a pub/sub message system like kafka or rabbitMQ, this table should be mounted with the message as a json object.
	 * Schema can optionally be store in the fieldset meta data using the "schema" key.
	 * As new messages are added into this table, triggers will process new rows and create corresponding entries in either the record, sequence or profile tables. 
	 * No schema is expected to be defined in this table, so the insert trigger needs to be customized which will server as a consumer.
	 */
	CREATE TABLE $POSTGRES_DB.messages (
        id          BIGSERIAL,
		fieldset_id	BIGINT NOT NULL,
		message		JSONB NULL,
		meta		JSONB NULL,
		ts			TIMESTAMP NULL DEFAULT NOW(),
		parsed		BOOLEAN DEFAULT FALSE,
		FOREIGN KEY (fieldset_id) REFERENCES $POSTGRES_DB.fieldsets(id)
	) PARTITION BY RANGE(ts);
	CREATE TABLE $POSTGRES_DB.messages_2025 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2025-01-01'::TIMESTAMP) TO ('2025-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2024 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2024-01-01'::TIMESTAMP) TO ('2024-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2023 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2023-01-01'::TIMESTAMP) TO ('2023-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2022 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2022-01-01'::TIMESTAMP) TO ('2022-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2021 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2021-01-01'::TIMESTAMP) TO ('2021-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2020 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2020-01-01'::TIMESTAMP) TO ('2020-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2019 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2019-01-01'::TIMESTAMP) TO ('2019-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2018 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2018-01-01'::TIMESTAMP) TO ('2018-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2017 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2017-01-01'::TIMESTAMP) TO ('2017-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2016 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2016-01-01'::TIMESTAMP) TO ('2016-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_2015 PARTITION OF $POSTGRES_DB.messages FOR VALUES FROM ('2015-01-01'::TIMESTAMP) TO ('2015-12-31'::TIMESTAMP);
	CREATE TABLE $POSTGRES_DB.messages_archive PARTITION OF $POSTGRES_DB.messages DEFAULT;
	
EOSQL