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
    fieldset_partition_tbl_name TEXT;
    fieldset_parent_token TEXT;
    partition_name TEXT;
    parent_partition_name TEXT;
    fieldset_records RECORD;
    field_type_record RECORD;
    col_data_type TEXT;
    partition_status RECORD;
    parent_partition_status RECORD;
    auth_string TEXT;
    fs_id BIGINT;
    fs RECORD;
    store_type_list TEXT[];
    store_type_name TEXT;
  BEGIN
    SELECT fieldsets.get_clickhouse_auth_string() INTO auth_string;
    FOR fieldset_records IN
      WITH partition_parents AS (
        SELECT
          B.parent,
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
          B.parent,
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
        array_agg(DISTINCT B.parent) AS ids,
        array_to_string(array_agg(DISTINCT B.parent),',') AS partition_ids
      FROM  new_fieldsets A,
        partition_parents B
      WHERE A.set_id = B.set_id
      GROUP BY A.set_id, A.set_token, B.store
    LOOP
      /**
       * FILTERS
       */
      IF fieldset_records.store = 'filter' THEN
        store_tbl_name := 'filters';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = fieldset_records.set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, fieldset_records.store);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);

        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) TABLESPACE %s;', partition_name, partition_name, fieldset_records.partition_ids, parent_partition_name, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_pkey PRIMARY KEY (id);', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_fkey FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_fkey FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
        ELSE
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT IF EXISTS %s_parent_chk;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT;', partition_name, partition_name, fieldset_records.partition_ids);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY fieldset_records.ids
        LOOP
          SELECT token, type INTO fs FROM new_fieldsets WHERE id = fs_id;
          IF fs IS NOT NULL THEN
            SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            EXECUTE sql_stmt;
            IF fs.type = 'fieldset'::TEXT THEN
              sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_%s_fkey FOREIGN KEY (%s) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name, fs.token, fs.token);
              EXECUTE sql_stmt;
            END IF;
          END IF;
        END LOOP;

      /**
       * RECORDS
       */
      ELSIF fieldset_records.store = 'record' THEN
        store_tbl_name := 'records';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = fieldset_records.set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, fieldset_records.store);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
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
          sql_stmt := format('CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) SERVER clickhouse_server;', partition_name, partition_name, fieldset_records.partition_ids, parent_partition_name);
          EXECUTE sql_stmt;
        ELSE
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %s_parent_chk;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT;', partition_name, partition_name, fieldset_records.partition_ids);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY fieldset_records.ids
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
      ELSIF fieldset_records.store = 'sequence' THEN
        store_tbl_name := 'sequences';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = fieldset_records.set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, fieldset_records.store);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          clickhouse_sql_stmt := format('
            CREATE TABLE IF NOT EXISTS fieldsets.%s (
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
          sql_stmt := format('CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) SERVER clickhouse_server;', partition_name, partition_name, fieldset_records.partition_ids, parent_partition_name);
          EXECUTE sql_stmt;
        ELSE
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %s_parent_chk;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT;', partition_name, partition_name, fieldset_records.partition_ids);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY fieldset_records.ids
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
      ELSIF fieldset_records.store = 'document' THEN
        store_tbl_name := 'documents';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = fieldset_records.set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, fieldset_records.store);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) TABLESPACE %s;', partition_name, partition_name, fieldset_records.partition_ids, parent_partition_name, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_pkey PRIMARY KEY (id);', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_fkey FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_fkey FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
        ELSE
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %s_parent_chk;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT;', partition_name, partition_name, fieldset_records.partition_ids);
          EXECUTE sql_stmt;
        END IF;

      /**
       * LOOKUPS
       */
      ELSIF fieldset_records.store = 'lookup' THEN
        store_tbl_name := 'lookups';

        SELECT parent_token INTO fieldset_parent_token FROM fieldsets.fieldsets WHERE token = fieldset_records.set_token;
        IF fieldset_parent_token = 'fieldset' OR fieldset_parent_token IS NULL THEN
          parent_partition_name := store_tbl_name;
        ELSE
          parent_partition_name := format('%s_%s', fieldset_parent_token, fieldset_records.store);
          SELECT to_regclass(format('fieldsets.%I',parent_partition_name)) INTO parent_partition_status;
          IF parent_partition_status IS NULL THEN
              parent_partition_name := store_tbl_name;
          END IF;
        END IF;

        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        SELECT to_regclass(format('fieldsets.%I',partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
          sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I(CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT) INHERITS (fieldsets.%I) TABLESPACE %s;', partition_name, partition_name, fieldset_records.partition_ids, parent_partition_name, store_tbl_name);
          EXECUTE sql_stmt;
          sql_stmt := format('CREATE INDEX IF NOT EXISTS %s_idx ON fieldsets.%I USING btree (id,parent);', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_id_fkey FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_fkey FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name);
          EXECUTE sql_stmt;
        ELSE
          sql_stmt := format('ALTER TABLE fieldsets.%I DROP CONSTRAINT %s_parent_chk;', partition_name, partition_name);
          EXECUTE sql_stmt;
          sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_parent_chk CHECK(parent IN (%s)) NO INHERIT;', partition_name, partition_name, fieldset_records.partition_ids);
          EXECUTE sql_stmt;
        END IF;

        FOREACH fs_id IN ARRAY fieldset_records.ids
        LOOP
          SELECT token, type INTO fs FROM new_fieldsets WHERE id = fs_id;
          IF fs IS NOT NULL THEN
            SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD COLUMN IF NOT EXISTS %s %s;', partition_name, fs.token, col_data_type);
            EXECUTE sql_stmt;
            sql_stmt := format('CREATE INDEX IF NOT EXISTS %s_%s_idx ON fieldsets.%I USING btree (%s);', partition_name, fs.token, partition_name, fs.token);
            EXECUTE sql_stmt;
            IF fs.type = 'fieldset'::TEXT THEN
              sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %s_%s_fkey FOREIGN KEY (%s) REFERENCES fieldsets.tokens(id) DEFERRABLE;', partition_name, partition_name, fs.token, fs.token);
              EXECUTE sql_stmt;
            END IF;
          END IF;
        END LOOP;

      /**
       * STREAMS
       */
      ELSIF fieldset_records.store = 'stream' THEN
        store_tbl_name := 'streams';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * VIEWS
       */
      ELSIF fieldset_records.store = 'view' THEN
        store_tbl_name := 'views';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * FILES
       */
      ELSIF fieldset_records.store = 'file' THEN
        store_tbl_name := 'files';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * PROGRAMS
       */
      ELSIF fieldset_records.store = 'program' THEN
        store_tbl_name := 'programs';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * CUSTOM
       */
      ELSIF fieldset_records.store = 'custom' THEN
        store_tbl_name := 'custom';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
        partition_name := format('%s_%s', fieldset_records.set_token, fieldset_records.store);
        -- TODO: Add in code

      /**
       * NONE
       */
      ELSIF fieldset_records.store = 'none' THEN
        store_tbl_name := 'none';
        fieldset_partition_tbl_name := format('__fieldsets_%s_%s', fieldset_records.set_token, fieldset_records.store);
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