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