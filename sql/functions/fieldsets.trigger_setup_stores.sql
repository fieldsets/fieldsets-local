/**
 * trigger_setup_stores: triggered after insert into fieldsets table. Setup all stores for values inserted.
 * @depends TRIGGER: trigger_30_setup_stores
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_setup_stores() RETURNS trigger AS $function$
  DECLARE
    clickhouse_sql_stmt TEXT;
    sql_stmt TEXT;
    conditional_sql TEXT;
    current_set_token TEXT;
    store_token TEXT;
    store_tbl_name TEXT;
    store_col_name TEXT;
    fieldset_parent_token TEXT;
    fieldset_parent_id BIGINT;
    partition_name TEXT;
    view_name TEXT;
    lookup_partition_name TEXT;
    partition_ids BIGINT[];
    partition_ids_string TEXT;
    parent_partition_name TEXT;
    fieldset_records RECORD;
    fieldset_parent_record RECORD;
    field_type_record RECORD;
    col_data_type TEXT;
    key_name TEXT;
    partition_status RECORD;
    parent_partition_status RECORD;
    auth_string TEXT;
    cron_job_token TEXT;
    cron_job_sql TEXT;
    fs_id BIGINT;
    fs FIELDSET_RECORD;
    fs_records FIELDSET_RECORD[];
    store_type_list TEXT[];
    store_type_name TEXT;
  BEGIN
    SELECT fieldsets.get_clickhouse_auth_string() INTO auth_string;
    FOR fieldset_records IN
      WITH partition_parents AS (
        SELECT
          A.parent,
          A.set_id,
          A.set_token,
          A.store
        FROM fieldsets.fieldsets A,
        new_fieldsets B
        WHERE A.store <> 'fieldset'
        AND B.store = 'fieldset'
        AND A.set_id = B.set_id
        UNION
        SELECT
          A.parent,
          A.set_id,
          A.set_token,
          A.store
        FROM fieldsets.fieldsets A,
        fieldsets.fieldsets B
        WHERE A.store <> 'fieldset'
        AND B.store = 'fieldset'
        AND A.set_id = B.set_id
        UNION
        SELECT
          parent,
          set_id,
          set_token,
          store
        FROM new_fieldsets
        WHERE store <> 'fieldset'
        UNION
        SELECT
          parent,
          set_id,
          set_token,
          store
        FROM fieldsets.fieldsets
        WHERE store <> 'fieldset'
      )
      SELECT
        A.set_id,
        A.set_token,
        B.store,
        array_agg(DISTINCT B.parent) AS ids
      FROM  new_fieldsets A,
        partition_parents B
      WHERE A.set_id = B.set_id
      AND B.parent <> 1
      GROUP BY A.set_id, A.set_token, B.store
    LOOP
      store_token := fieldset_records.store;
      current_set_token := fieldset_records.set_token;
      partition_ids := fieldset_records.ids;

      -- Create an array of fieldset records that we are going to use to setup the stores.
      -- We then call functions that can be overwritten to handle the different store type for other data solutions.
      SELECT array_agg((id, token, label, parent, parent_token, set_id, set_token, field_id, field_token, type, store)::FIELDSET_RECORD)
      INTO fs_records
      FROM new_fieldsets
      WHERE id IN (SELECT unnest(partition_ids));

      /**
       * FILTERS
       */
      IF store_token = 'filter' THEN
        CALL fieldsets.setup_filter_store_partition(current_set_token, fs_records);
      /**
       * RECORDS
       */
      ELSIF store_token = 'record' THEN
        store_tbl_name := 'records';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = current_set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, store_token);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        partition_ids_string := array_to_string(partition_ids,',');
        partition_name := format('%s_%s', current_set_token, store_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          clickhouse_sql_stmt := format('
            CREATE TABLE IF NOT EXISTS fieldsets.%I (
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

          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) SERVER clickhouse_server;', partition_name, key_name, partition_ids_string, parent_partition_name);
          EXECUTE sql_stmt;
        ELSE

          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %I;', partition_name, key_name);
          EXECUTE sql_stmt;

          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT;', partition_name, key_name, partition_ids_string);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY partition_ids
        LOOP
          SELECT token, type INTO fs FROM new_fieldsets WHERE id = fs_id;
          IF fs IS NOT NULL THEN
            SELECT fieldsets.get_field_data_type(fs.type::TEXT,'clickhouse') INTO col_data_type;
            clickhouse_sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
            EXECUTE sql_stmt;
            SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            EXECUTE sql_stmt;
          END IF;
        END LOOP;

      /**
       * SEQUENCES
       */
      ELSIF store_token = 'sequence' THEN
        store_tbl_name := 'sequences';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = current_set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, store_token);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        partition_ids_string := array_to_string(partition_ids,',');
        partition_name := format('%s_%s', current_set_token, store_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          clickhouse_sql_stmt := format('
            CREATE TABLE IF NOT EXISTS fieldsets.%I (
                id          UInt64,
                parent      UInt64,
                position    Int64
            )
            ENGINE = MergeTree()
            PARTITION BY position
            ORDER BY (parent, id, position);
          ', partition_name);
          sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
          EXECUTE sql_stmt;

          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) SERVER clickhouse_server;', partition_name, key_name, partition_ids_string, parent_partition_name);
          EXECUTE sql_stmt;
        ELSE
          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %I;', partition_name, key_name);
          EXECUTE sql_stmt;

          key_name := format('%s_parent_chk', partition_name);
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT;', partition_name, key_name, partition_ids_string);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY partition_ids
        LOOP
          SELECT token, type INTO fs FROM new_fieldsets WHERE id = fs_id;
          IF fs IS NOT NULL THEN
            SELECT fieldsets.get_field_data_type(fs.type::TEXT,'clickhouse') INTO col_data_type;
            clickhouse_sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
            EXECUTE sql_stmt;
            SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            EXECUTE sql_stmt;
          END IF;
        END LOOP;

      /**
       * DOCUMENTS
       */
      ELSIF store_token = 'document' THEN
        store_tbl_name := 'documents';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = current_set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
            parent_partition_name := store_tbl_name;
        ELSE
            parent_partition_name := format('%s_%s', fieldset_parent_token, store_token);
            SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
            IF parent_partition_status IS NULL THEN
                parent_partition_name := store_tbl_name;
            END IF;
        END IF;

        partition_ids_string := array_to_string(partition_ids,',');
        partition_name := format('%s_%s', current_set_token, store_token);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN

            key_name := format('%s_parent_chk', partition_name);
            sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) TABLESPACE %I;', partition_name, key_name, partition_ids_string, parent_partition_name, store_tbl_name);
            EXECUTE sql_stmt;

            key_name := format('%s_id_pkey', partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I PRIMARY KEY (id);', partition_name, key_name);
            EXECUTE sql_stmt;

            key_name := format('%s_id_fkey', partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, key_name);
            EXECUTE sql_stmt;

            key_name := format('%s_parent_fkey', partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, key_name);
            EXECUTE sql_stmt;
        ELSE
            key_name := format('%s_parent_chk', partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %I;', partition_name, key_name);
            EXECUTE sql_stmt;

            key_name := format('%s_parent_chk', partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I CHECK(parent IN (%s)) NO INHERIT;', partition_name, key_name, partition_ids_string);
            EXECUTE sql_stmt;
        END IF;
      /**
       * LOOKUPS
       */
      ELSIF store_token = 'lookup' THEN
        store_tbl_name := 'lookups';

        SELECT id,token,parent,parent_token,set_id,set_token,field_id,field_token,type,store INTO fieldset_parent_record
        FROM fieldsets.fieldsets
        WHERE token = current_set_token;

        fieldset_parent_token := fieldset_parent_record.parent_token;
        fieldset_parent_id := fieldset_parent_record.parent;

        --IF fieldset_parent_record.parent <> fieldset_parent_record.id THEN
        --  partition_ids := array_remove(partition_ids,fieldset_parent_id);
        --END IF;

        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
            parent_partition_name := store_tbl_name;
        ELSE
            parent_partition_name := format('%s_%s', fieldset_parent_token, store_token);
            SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
            IF parent_partition_status IS NULL THEN
                parent_partition_name := store_tbl_name;
            END IF;
        END IF;

        partition_ids_string := array_to_string(partition_ids,',');
        partition_name := format('__%s_%s', current_set_token, store_token);

        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
            conditional_sql := '';
            IF parent_partition_name = store_tbl_name THEN
            conditional_sql := 'PARTITION BY LIST(parent)';
            END IF;
            sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.%I FOR VALUES IN(%s) %s TABLESPACE %I;', partition_name, parent_partition_name, partition_ids_string, conditional_sql, store_tbl_name);
            EXECUTE sql_stmt;
        ELSE
            sql_stmt := format('ALTER TABLE fieldsets.%I DETACH PARTITION fieldsets.%I;', parent_partition_name, partition_name);
            EXECUTE sql_stmt;
            sql_stmt := format('ALTER TABLE fieldsets.%I ATTACH PARTITION fieldsets.%I FOR VALUES IN (%s);', parent_partition_name, partition_name, partition_ids_string);
            EXECUTE sql_stmt;
        END IF;
        /*
            * Create a partitions for the lookup fields
            */
        FOREACH fs_id IN ARRAY partition_ids
        LOOP
            SELECT token, type, field_id, field_token INTO fs FROM new_fieldsets WHERE id = fs_id;
            IF fs IS NOT NULL THEN
            partition_status := NULL;
            SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
            lookup_partition_name := format('__%s_%s', fs.field_token, store_token);
            SELECT to_regclass(format('fieldsets.%I',lookup_partition_name)) INTO partition_status;
            IF partition_status IS NULL THEN
                sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.%I FOR VALUES IN(%s) TABLESPACE %I;', lookup_partition_name, partition_name, fs_id::TEXT, store_tbl_name);
                EXECUTE sql_stmt;
                key_name := format('%s_value_idx', lookup_partition_name);
                sql_stmt := format('CREATE INDEX IF NOT EXISTS %I ON fieldsets.%I USING HASH (((value).%s));', key_name, lookup_partition_name, fs.type::TEXT);
                EXECUTE sql_stmt;
                key_name := format('%s_id_fkey', lookup_partition_name);
                sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', lookup_partition_name, key_name);
                EXECUTE sql_stmt;
                key_name := format('%s_parent_fkey', lookup_partition_name);
                sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', lookup_partition_name, key_name);
                EXECUTE sql_stmt;

                /*
                IF fs.type::TEXT = 'fieldset'::TEXT THEN
                key_name := format('%s_value_fkey', lookup_partition_name);
                sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (((value).%s)) REFERENCES fieldsets.tokens(id) DEFERRABLE;', lookup_partition_name, key_name, fs.type::TEXT);
                EXECUTE sql_stmt;
                END IF;
                */

                view_name := format('%s_%s', fs.field_token, store_token);
                sql_stmt := format('CREATE OR REPLACE VIEW fieldsets.%I AS SELECT id, parent, (value).%s AS value, created, updated FROM fieldsets.%I;', view_name, fs.type::TEXT, lookup_partition_name);
                EXECUTE sql_stmt;
                /**
                * Create A clickhouse dictionary for our lookup.
                */

                SELECT fieldsets.get_field_data_type(fs.type::TEXT,'clickhouse') INTO col_data_type;
                clickhouse_sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I (
                id UInt64,
                parent UInt64,
                value %s,
                created DateTime,
                updated DateTime
                ) ENGINE = PostgreSQL(
                    %s,
                    table = %L
                );', lookup_partition_name, col_data_type, 'postgres_connection', lookup_partition_name);
                sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
                EXECUTE sql_stmt;
                clickhouse_sql_stmt := format('CREATE OR REPLACE DICTIONARY IF NOT EXISTS fieldsets.%I_dict (
                id UInt64,
                value %s
                )
                PRIMARY KEY value, id
                SOURCE(CLICKHOUSE(TABLE ''fieldsets.%I''))
                LAYOUT(HASHED())
                LIFETIME(0);', fs.field_token, col_data_type, lookup_partition_name);
                sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
                EXECUTE sql_stmt;
                /*
                clickhouse_sql_stmt := format('CREATE MATERIALIZED VIEW IF NOT EXISTS fieldsets.%I
                TO fieldsets.%I_dict AS
                SELECT id,
                    value
                FROM fieldsets.%I;', fs.field_token, fs.field_token, fs.type::TEXT, lookup_partition_name);
                sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
                EXECUTE sql_stmt;
                */
            END IF;
            END IF;
        END LOOP;

      /**
       * STREAMS
       */
      ELSIF store_token = 'stream' THEN
        store_tbl_name := 'streams';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * VIEWS
       */
      ELSIF store_token = 'view' THEN
        store_tbl_name := 'views';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * FILES
       */
      ELSIF store_token = 'file' THEN
        store_tbl_name := 'files';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * PROGRAMS
       */
      ELSIF store_token = 'program' THEN
        store_tbl_name := 'programs';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * CUSTOM
       */
      ELSIF store_token = 'custom' THEN
        store_tbl_name := 'custom';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * NONE
       */
      ELSIF store_token = 'none' THEN
        store_tbl_name := 'none';
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * ANY
       */
      ELSE --'any' type
        store_tbl_name := 'any';
        partition_name := format('%s_%s', store_tbl_name, fieldset_records.set_token);
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