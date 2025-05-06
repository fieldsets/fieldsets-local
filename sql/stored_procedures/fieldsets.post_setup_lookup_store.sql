/**
 * post_setup_lookup_store: Setup a seconary store for lookups using clickhouse dictionaries.
 * @param FIELDSET_RECORD: fs_record
 * @param FIELDSET_RECORD[]: fs_child_records
 **/
CREATE OR REPLACE PROCEDURE fieldsets.post_setup_lookup_store(fs_record FIELDSET_RECORD, fs_child_records FIELDSET_RECORD[]) AS $procedure$
DECLARE
    store_token TEXT;
    store_tbl_name TEXT;
    partition_status RECORD;
    lookup_partition_name TEXT;
    fs FIELDSET_RECORD;
    key_name TEXT;
    col_data_type TEXT;
    sql_stmt TEXT;
    clickhouse_sql_stmt TEXT;
    auth_string TEXT;
BEGIN
    store_token := 'lookup';
   	store_tbl_name := 'lookups';

    SELECT fieldsets.get_clickhouse_auth_string() INTO auth_string;

    /**
     * Create a partitions for the lookup fields
     **/
    FOREACH fs IN ARRAY fs_child_records
    LOOP
        IF fs IS NOT NULL THEN
        partition_status := NULL;
        SELECT fieldsets.get_field_data_type(fs.type::TEXT) INTO col_data_type;
        lookup_partition_name := format('__%s_%s', fs.field_token, store_token);
        SELECT to_regclass(format('fieldsets.%I',lookup_partition_name)) INTO partition_status;
        -- Make sure the postgres partion exists before we create the clickhouse dictionary
        IF partition_status IS NOT NULL THEN
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
END;
$procedure$ LANGUAGE plpgsql;

COMMENT ON PROCEDURE fieldsets.post_setup_lookup_store(FIELDSET_RECORD,FIELDSET_RECORD[]) IS
'/**
 * post_setup_lookup_store: Takes a fieldset token and associated ids and creates partitions for the given STORE_TYPE.
 * @param FIELDSET_RECORD: fs_record
 * @param FIELDSET_RECORD[]: fs_child_records
 **/';
