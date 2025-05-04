/**
 * trigger_setup_stores: triggered after insert into fieldsets table. Setup all stores for values inserted.
 * @depends TRIGGER: trigger_30_setup_stores
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_setup_stores() RETURNS trigger AS $function$
  DECLARE
    fieldset_records RECORD;
    store_token TEXT;
    current_set_token TEXT;
    partition_ids BIGINT[];
    fs_record FIELDSET_RECORD;
    fs_child_records FIELDSET_RECORD[];
    proc_name TEXT;
    sql_stmt TEXT;
  BEGIN
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

      SELECT id, token, label, parent, parent_token, set_id, set_token, field_id, field_token, type, store
      INTO fs_record
      FROM fieldsets.fieldsets
      WHERE token = current_set_token;

      -- Create an array of fieldset records that we are going to use to setup the stores.
      -- We then call functions that can be overwritten to handle the different store type for other data solutions.
      SELECT array_agg(ROW(id, token, label, parent, parent_token, set_id, set_token, field_id, field_token, type, store)::FIELDSET_RECORD)
      INTO fs_child_records
      FROM fieldsets.fieldsets
      WHERE id IN (SELECT unnest(partition_ids));

      /**
       * FILTERS
       */
      IF store_token = 'filter' THEN
        CALL fieldsets.setup_filter_store(fs_record, fs_child_records);

      /**
       * RECORDS
       */
      ELSIF store_token = 'record' THEN
        CALL fieldsets.setup_record_store(fs_record, fs_child_records);

      /**
       * SEQUENCES
       */
      ELSIF store_token = 'sequence' THEN
        CALL fieldsets.setup_sequence_store(fs_record, fs_child_records);

      /**
       * DOCUMENTS
       */
      ELSIF store_token = 'document' THEN
        CALL fieldsets.setup_document_store(fs_record, fs_child_records);

      /**
       * LOOKUPS
       */
      ELSIF store_token = 'lookup' THEN
        CALL fieldsets.setup_lookup_store(fs_record, fs_child_records);

      /**
       * All other store types:
       */
      ELSE
        BEGIN 
          proc_name := format('setup_%s_store', store_token);
          sql_stmt := format('CALL fielsets.%I(%L, %L)', proc_name, fs_record, fs_child_records);
          EXECUTE sql_stmt;
        EXCEPTION WHEN case_not_found THEN
          RAISE NOTICE 'Cannot Find Store Procedure %. Skipping store setup for %', proc_name, current_set_token;
        END;
        
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