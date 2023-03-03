/**
 * trigger_copy_data_row: triggered function to copy data from one table to a copy of that table in another schema.
 * @param table_name TEXT: table name 
 * @param target_schema TEXT: schema of copy of table to write/sync to 
 * @param source_schema TEXT: origin table schema to read from
 **/
CREATE OR REPLACE FUNCTION trigger_copy_data_row() RETURNS trigger AS $function$
  DECLARE
    table_name TEXT := TG_ARGV[0];
    source_schema TEXT := TG_ARGV[1];
    target_schema TEXT := TG_ARGV[2];
    col_store JSONB;
    col_list RECORD;
  BEGIN

    EXECUTE format('SET client_min_messages TO WARNING; CREATE TABLE IF NOT EXISTS %I.%I (LIKE %I.%I INCLUDING ALL);', target_schema, table_name, source_schema, table_name);
    SELECT to_jsonb(NEW) INTO col_store;
	  SELECT string_agg(quote_ident(key), ',') AS keys, string_agg(quote_nullable(value), ',') AS vals FROM (SELECT key, value FROM jsonb_each_text(col_store)) new_store INTO col_list;
	  EXECUTE format('INSERT INTO %I.%I (%s) VALUES (%s) ON CONFLICT DO NOTHING;', target_schema, table_name, col_list.keys, col_list.vals);

    RETURN NEW;
  END;
$function$ 
SECURITY DEFINER
LANGUAGE plpgsql;

COMMENT ON FUNCTION trigger_copy_data_row () IS 
'/**
 * trigger_copy_data_row: triggered function to copy data from one table to a copy of that table in another schema.
 * @param table_name TEXT: table name 
 * @param target_schema TEXT: schema of copy of table to write/sync to 
 * @param source_schema TEXT: origin table schema to read from
 **/';