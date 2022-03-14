# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE OR REPLACE FUNCTION fieldsets.create_profile_partition(fieldset_id BIGINT, token_name TEXT) RETURNS VOID
    AS \$function\$
        DECLARE
            partition_sql TEXT;
            partition_tbl TEXT;
        BEGIN
            partition_tbl := FORMAT('profiles_%s', token_name);
            partition_sql := FORMAT('CREATE TABLE IF NOT EXISTS fieldsets.%I PARTITION OF fieldsets.profiles FOR values IN ( %L )', partition_tbl, fieldset_id);
            RAISE NOTICE 'Creating Profile Partition % for ID %', partition_tbl, fieldset_id;
            EXECUTE partition_sql;
        END;
    \$function\$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION fieldsets.create_profile_dictionary(set_id BIGINT, token_name TEXT) RETURNS VOID
    AS \$function\$
        DECLARE
            dict_name TEXT;
            dict_sql TEXT;
            dict_cols_sql TEXT;
        BEGIN
            dict_name := FORMAT('%s_profile_dict', token_name);

            -- Check Clickhouse FDW extension 
            BEGIN 
                EXECUTE 'SELECT "clickhousedb_raw_query"::regproc';
                RAISE NOTICE 'Creating ClickHouse Dictionary %', dict_name;
                dict_sql := FORMAT('SELECT public.clickhousedb_raw_query( CREATE TABLE %I (id UInt64, updated_ts DateTime DEFAULT NOW() Codec(DoubleDelta, LZ4)) Engine = Dictionary(%I))', dict_name, dict_name);
                EXECUTE dict_sql;
            EXCEPTION WHEN undefined_function THEN
                RAISE NOTICE 'ClickHouse FDW not installed';
            END;
        END;
    \$function\$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION fieldsets.create_fields_dictionary(set_id BIGINT, fieldset_id BIGINT, token_name TEXT) RETURNS VOID
    AS \$function\$
        DECLARE
            dict_name TEXT;
            dict_sql TEXT;
            dict_cols_sql TEXT;
        BEGIN
            dict_name := FORMAT('%s_profile_fields_dict', token_name);

            -- Check Clickhouse FDW extension 
            BEGIN 
                EXECUTE 'SELECT "clickhousedb_raw_query"::regproc';
                RAISE NOTICE 'Creating ClickHouse Dictionary %', dict_name;
                dict_sql := FORMAT('SELECT public.clickhousedb_raw_query( CREATE TABLE %I (id UInt64, updated_ts DateTime DEFAULT NOW() Codec(DoubleDelta, LZ4)) Engine = Dictionary(%I))', dict_name, dict_name);
                EXECUTE dict_sql;
            EXCEPTION WHEN undefined_function THEN
                RAISE NOTICE 'ClickHouse FDW not installed';
            END;
        END;
    \$function\$ LANGUAGE plpgsql;

EOSQL