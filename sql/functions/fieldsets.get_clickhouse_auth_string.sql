/**
 * get_clickhouse_auth_string: Generate an authentication string to use with the function clickhousedb_raw_query
 * @return TEXT: 'dbname=$CLICKHOUSE_DB host=$CLICKHOUSE_HOST port=$CLICKHOUSE_PORT username=$CLICKHOUSE_USER password=$CLICKHOUSE_PASSWORD'
 **/
CREATE OR REPLACE FUNCTION fieldsets.get_clickhouse_auth_string() RETURNS TEXT AS $function$
    DECLARE
        dbinfo TEXT;
        dbusername TEXT;
        dbpassword TEXT;
        auth_string TEXT;
    BEGIN
        SELECT array_to_string(srvoptions, ' ') INTO dbinfo
        FROM pg_foreign_server
        WHERE oid=(
            SELECT srvid
            FROM pg_user_mappings
            WHERE usename=(SELECT current_user)
            LIMIT 1
        );

        SELECT split_part(umoptions[1], '=', 2) INTO dbusername
        FROM pg_user_mappings
        WHERE usename=(SELECT current_user) LIMIT 1;

        SELECT split_part(umoptions[2], '=', 2) INTO dbpassword
        FROM pg_user_mappings
        WHERE usename=(SELECT current_user) LIMIT 1;

        SELECT concat_ws(' ', dbinfo, concat('username=', dbusername), concat('password=', dbpassword)) INTO auth_string;
        RETURN auth_string;
    END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.get_clickhouse_auth_string() IS
'/**
 * get_clickhouse_auth_string: Generate an authentication string to use with the function clickhousedb_raw_query
 * @return TEXT: `dbname=$CLICKHOUSE_DB host=$CLICKHOUSE_HOST port=$CLICKHOUSE_PORT username=$CLICKHOUSE_USER password=$CLICKHOUSE_PASSWORD`
 **/';