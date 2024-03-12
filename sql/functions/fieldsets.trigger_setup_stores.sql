/**
 * trigger_setup_stores: triggered after insert into fieldsets table. Setup all stores for values inserted.
 * @depends TRIGGER: trigger_30_setup_stores
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_setup_stores() RETURNS trigger AS $function$
  DECLARE
    clickhouse_sql_stmt TEXT;
    sql_stmt TEXT;
    store_tbl_name TEXT;
    store_col_name TEXT;
    partition_name TEXT;
    fieldset_records RECORD;
    col_data_type TEXT;
    partition_status RECORD;
    auth_string TEXT;
  BEGIN
    SELECT fieldsets.get_clickhouse_auth_string() INTO auth_string;
    FOR fieldset_records IN
      SELECT
        id,
        token,
        parent,
        parent_token,
        set_id,
        field_id,
        type,
        store
      FROM new_fieldsets
      WHERE parent > 1
    LOOP
      RAISE NOTICE 'Fieldset: (%,%,%,%,%,%,%,%)', fieldset_records.id, fieldset_records.token, fieldset_records.parent, fieldset_records.parent_token, fieldset_records.set_id, fieldset_records.field_id, fieldset_records.type, fieldset_records.store;
      -- FILTERS
      IF fieldset_records.store = 'filter' THEN
        store_tbl_name := 'filters';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);

        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I(CHECK(parent=%s)) INHERITS (fieldsets.%I) TABLESPACE %I;', partition_name, fieldset_records.parent, store_tbl_name, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format(' ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_pkey PRIMARY KEY (id);', partition_name, partition_name, col_data_type, fieldset_records.token);
          EXECUTE sql_stmt;
        END IF;
        SELECT fieldsets.get_field_data_type(fieldset_records.type::TEXT) INTO col_data_type;
        sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fieldset_records.token, col_data_type);
        EXECUTE sql_stmt;
      --RECORDS
      ELSIF fieldset_records.store = 'record' THEN
        store_tbl_name := 'records';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          clickhouse_sql_stmt := format('
            CREATE TABLE IF NOT EXISTS fieldsets.%s (
                id		    UInt64,
                parent      UInt64,
                created     DateTime64(3) DEFAULT now64(3)
            )
            ENGINE = MergeTree()
            PARTITION BY toYYYYMM(created)
            ORDER BY (parent, id, created);
          ', partition_name);
          sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
          EXECUTE sql_stmt;
          sql_stmt := format('CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.%I(CHECK(parent=%s)) INHERITS (fieldsets.%I) SERVER clickhouse_server;', partition_name, fieldset_records.parent, store_tbl_name);
          EXECUTE sql_stmt;
        END IF;
        SELECT fieldsets.get_field_data_type(fieldset_records.type::TEXT,'clickhouse') INTO col_data_type;
        clickhouse_sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fieldset_records.token, col_data_type);
        sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
        EXECUTE sql_stmt;
        SELECT fieldsets.get_field_data_type(fieldset_records.type::TEXT) INTO col_data_type;
        sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fieldset_records.token, col_data_type);
        EXECUTE sql_stmt;
      -- SEQUENCES
      ELSIF fieldset_records.store = 'sequence' THEN
        store_tbl_name := 'sequences';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      -- DOCUMENTS
      ELSIF fieldset_records.store = 'document' THEN
        store_tbl_name := 'documents';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.%I FOR VALUES IN (%s) TABLESPACE %I;', partition_name, store_tbl_name, fieldset_records.parent, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format(' ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_pkey PRIMARY KEY (id);', partition_name, partition_name, col_data_type, fieldset_records.token);
          EXECUTE sql_stmt;
        END IF;
      -- LOOKUPS
      ELSIF fieldset_records.store = 'lookup' THEN
        store_tbl_name := 'lookups';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.%I FOR VALUES IN (%s) TABLESPACE %I;', partition_name, store_tbl_name, fieldset_records.parent, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format(' ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_pkey PRIMARY KEY (id);', partition_name, partition_name, col_data_type, fieldset_records.token);
          EXECUTE sql_stmt;
        END IF;
      ELSIF fieldset_records.store = 'stream' THEN
        store_tbl_name := 'streams';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSIF fieldset_records.store = 'view' THEN
        store_tbl_name := 'views';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSIF fieldset_records.store = 'file' THEN
        store_tbl_name := 'files';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSIF fieldset_records.store = 'program' THEN
        store_tbl_name := 'programs';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSIF fieldset_records.store = 'custom' THEN
        store_tbl_name := 'custom';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSIF fieldset_records.store = 'none' THEN
        store_tbl_name := 'none';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      ELSE --'any' type
        store_tbl_name := 'any';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.parent_token);
        -- TODO: Add in code
      END IF;
    END LOOP;
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.trigger_setup_stores() IS
'/**
 * trigger_setup_stores: triggered after insert into fieldsets table. Setup all stores for values inserted.
 * @depends TRIGGER: trigger_30_setup_stores
 **/';