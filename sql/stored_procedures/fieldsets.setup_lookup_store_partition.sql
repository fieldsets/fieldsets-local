/**
 * setup_lookup_store_partition: takes a table name and generates a given number of subpartitions for all enumerated STORE_TYPEs.
 * @param TEXT: set_token
 * @param BIGINT[]: partition_ids
 **/
CREATE OR REPLACE PROCEDURE fieldsets.setup_lookup_store_partition(set_token TEXT, partition_ids BIGINT[], fs_tbl REGCLASS) AS $procedure$
DECLARE
    store_token TEXT;
    store_tbl_name TEXT;
    fieldset_parent_record RECORD;
    fieldset_parent_token TEXT;
    fieldset_parent_id BIGINT;
    parent_partition_name TEXT;
    parent_partition_status RECORD;
    partition_name TEXT;
    partition_status RECORD;
    partition_ids_string TEXT;
    lookup_partition_name TEXT;
    fs_id BIGINT;
    fs RECORD;
    key_name TEXT;
    col_data_type TEXT;
    sql_stmt TEXT;
    conditional_sql TEXT;
    clickhouse_sql_stmt TEXT;
    auth_string TEXT;
BEGIN
    store_token := 'lookup';
   	store_tbl_name := 'lookups';

    SELECT id,token,parent,parent_token,set_id,set_token,field_id,field_token,type,store INTO fieldset_parent_record
    FROM fieldsets.fieldsets
    WHERE token = set_token;

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
    partition_name := format('%s_%s', set_token, store_token);

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
        SELECT token, type, field_id, field_token INTO fs FROM fs_tbl WHERE id = fs_id;
        IF fs IS NOT NULL THEN
        partition_status := NULL;
        SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
        lookup_partition_name := format('%s_%s', fs.field_token, store_token);
        SELECT to_regclass(format('fieldsets.%I',lookup_partition_name)) INTO partition_status;
        IF partition_status IS NULL THEN
            sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.%I FOR VALUES IN(%s) TABLESPACE %I;', lookup_partition_name, partition_name, fs_id::TEXT, store_tbl_name);
            EXECUTE sql_stmt;
            key_name := format('%s_value_idx', partition_name);
            sql_stmt := format('CREATE INDEX IF NOT EXISTS %I ON fieldsets.%I USING HASH (((value).%s));', key_name, partition_name, fs.type::TEXT);
            EXECUTE sql_stmt;
            key_name := format('%s_id_fkey', lookup_partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (id) REFERENCES fieldsets.tokens(id) DEFERRABLE;', lookup_partition_name, key_name);
            EXECUTE sql_stmt;
            key_name := format('%s_parent_fkey', lookup_partition_name);
            sql_stmt := format('ALTER TABLE fieldsets.%I ADD CONSTRAINT %I FOREIGN KEY (parent) REFERENCES fieldsets.tokens(id) DEFERRABLE;', lookup_partition_name, key_name);
            EXECUTE sql_stmt;

            -- @TODO: Add in foreign key to value.fieldset - the field of field_value data type.
            --IF fs.type::TEXT = 'fieldset'::TEXT THEN
            --EXECUTE sql_stmt;
            --END IF;
            /**
            * Create A clickhouse dictionary for our lookup.
            */

            SELECT fieldsets.get_field_data_type(fs.type::TEXT,'clickhouse') INTO col_data_type;
            clickhouse_sql_stmt := format('CREATE TABLE IF NOT EXISTS fieldsets.%I (
            id UInt64,
            parent UInt64,
            value Nested(
                fieldset UInt64,
                string String,
                number Int64,
                decimal Decimal,
                object String,
                list Array(Nullable(String)),
                array Array(Nullable(Decimal)),
                vector Array(Nullable(String)),
                bool Boolean,
                date Date,
                ts DateTime,
                search String,
                uuid UUID,
                function String,
                enum String,
                custom String,
                any String
            )
            ) ENGINE = PostgreSQL(
                %s,
                table = %L
            );', lookup_partition_name, 'postgres_connection', lookup_partition_name);
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
            clickhouse_sql_stmt := format('CREATE MATERIALIZED VIEW IF NOT EXISTS fieldsets.%I
            TO fieldsets.%I_dict AS
            SELECT id,
                value.%s AS value
            FROM fieldsets.%I;', fs.field_token, fs.field_token, fs.type::TEXT, lookup_partition_name);
            sql_stmt := format('SELECT clickhousedb_raw_query(%L,%L);', clickhouse_sql_stmt, auth_string);
            EXECUTE sql_stmt;
        END IF;
        END IF;
    END LOOP;
END;
$procedure$ LANGUAGE plpgsql;

COMMENT ON PROCEDURE fieldsets.setup_lookup_store_partition(TEXT,BIGINT[],REGCLASS) IS
'/**
 * setup_lookup_store_partition: takes a table name and generates a given number of subpartitions for all enumerated STORE_TYPEs.
 * @param TEXT: parent_partition (optional -default "fieldsets")
 * @param TEXT: parent_token (optional -default "fieldset")
 * @param TEXT: table_space (optional -default "fieldsets")
 **/';
