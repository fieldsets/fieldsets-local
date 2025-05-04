/**
 * setup_sequence_store: Takes a fieldset token and associated ids and creates partitions for the given STORE_TYPE.
 * @param FIELDSET_RECORD: fs_record
 * @param FIELDSET_RECORDS[]: fs_child_records
 **/
CREATE OR REPLACE PROCEDURE fieldsets.setup_sequence_store(fs_record FIELDSET_RECORD, fs_child_records FIELDSET_RECORD[]) AS $procedure$
DECLARE
    store_token TEXT;
    store_tbl_name TEXT;
    fieldset_parent_token TEXT;
    parent_partition_name TEXT;
    parent_partition_status RECORD;
    partition_name TEXT;
    partition_status RECORD;
    partition_ids BIGINT[];
    partition_ids_string TEXT;
    fs FIELDSET_RECORD;
    key_name TEXT;
    col_data_type TEXT;
    sql_stmt TEXT;
    clickhouse_sql_stmt TEXT;
    auth_string TEXT;
BEGIN
    store_token := 'sequence';
    store_tbl_name := 'sequences';
    fieldset_parent_token := fs_record.token;

    SELECT fieldsets.get_clickhouse_auth_string() INTO auth_string;

    SELECT array_agg(DISTINCT id) INTO partition_ids FROM unnest(fs_child_records);

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
    partition_name := format('%s_%s', fs_record.token, store_token);
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

    FOREACH fs IN ARRAY fs_child_records
    LOOP
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
END;
$procedure$ LANGUAGE plpgsql;

COMMENT ON PROCEDURE fieldsets.setup_sequence_store(FIELDSET_RECORD,FIELDSET_RECORD[]) IS
'/**
 * setup_sequence_store: Takes a fieldset token and associated ids and creates partitions for the given STORE_TYPE.
 * @param FIELDSET_RECORD: fs_record
 * @param FIELDSET_RECORDS[]: fs_child_records
 **/';
