#!/bin/bash
set -e

# Insert Config
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  INSERT INTO public.config (id, token, description, value, meta)
  	VALUES
  	  (0, 'fieldsets-version', 'Fieldsets Version', '0.0.1', '{}'::jsonb),
		  (1, 'fieldsets-init-date', 'Fieldsets Init Date', now(), '{}'::jsonb),
		  (2, 'fieldsets-last-update', 'Fieldsets Init Date', 'none', '{}'::jsonb),
      (100, 'postgres-major-version', 'PostgreSQL Major Version', '${POSTGRES_VERSION}', '{}'::jsonb),
		  (101, 'postgres-version', 'PostgreSQL version', version(), '{}'::jsonb);
EOSQL

# Insert Sets
# These core sets are defined to allow for the definition of the data structure stored in the JSONB data fields that will be determined by the application interacting with the FieldSets Framework.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  INSERT INTO fieldsets.sets (id, token, label, description, parent, meta)
  VALUES
    (0,'set','Set','An abstract set', 0,'{}'::jsonb),
    (1, 'defaults', 'Default Values', 'A set of all field types and their default values', 0, '{}'::jsonb);
EOSQL

# Insert Fields
# field_value composite data type is of format:
#(
#   "string"		  TEXT, # ex: 'something'
#		"number"		  BIGINT, # ex: 0
#		"decimal"		  DECIMAL, # ex: 0.0
#		"object"		  JSONB, # ex: '{"key":"value"}'::jsonb
#		"list" 			  TEXT[], # ex: '{"A","B","C"}'
#		"bool" 			  BOOLEAN, # ex: FALSE
#		"date" 			  DATE, # ex: NOW::date
#		"ts"	        TIMESTAMP, # ex: NOW(),
#   "function"    JSONB # ex: '{"name":"function_name","source":"client-js","params":[]}'::jsonb
#)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  INSERT INTO fieldsets.fields (id, token, label, description, primary_set, type, default_value, default_position, parent, meta)
  VALUES
    (0, 'field', 'Field', 'An abstract field', 0, 'string', (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL), 0, 0, '{}'::jsonb),
    (1, 'string-field', 'String Field', 'An abstract character field', 1, 'string', ('',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL), 0, 0, '{}'::jsonb),
    (2, 'number-field', 'Number Field', 'An abstract integer field', 1, 'number', (NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL), 1, 0, '{}'::jsonb),
    (3, 'decimal-field', 'Decimal Field', 'An abstract float field', 1, 'decimal', (NULL,NULL,0.0,NULL,NULL,NULL,NULL,NULL,NULL), 2, 0, '{}'::jsonb),
    (4, 'object-field', 'Object Field', 'An abstract json object field', 1, 'object', (NULL,NULL,NULL,'{}'::json,NULL,NULL,NULL,NULL,NULL), 3, 0, '{}'::jsonb),
    (5, 'list-field', 'List Field', 'An abstract array field', 1, 'list', (NULL,NULL,NULL,NULL,'{}',NULL,NULL,NULL,NULL), 4, 0, '{}'::jsonb),
    (6, 'bool-field', 'Boolean Field', 'An abstract boolean field', 1, 'bool', (NULL,NULL,NULL,NULL,NULL,FALSE,NULL,NULL,NULL), 5, 0, '{}'::jsonb),
    (7, 'date-field', 'Date Field', 'An abstract date field', 1, 'date', (NULL,NULL,NULL,NULL,NULL,NULL,NOW()::date,NULL,NULL), 6, 0, '{}'::jsonb),
    (8, 'ts-field', 'Timestamp Field', 'An abstract timestamp field', 1, 'ts', (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NOW(),NULL), 7, 0, '{}'::jsonb),
    (9, 'function-field', 'Function Field', 'An abstract function field', 1, 'function', (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'{"name":"","source":"","params":[]}'::json), 8, 0, '{}'::jsonb);
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  INSERT INTO fieldsets.fieldsets (id, token, type, store, source, set_id, parent, meta)
    VALUES
      (0, 'fieldset', NULL, 'none', NULL, 0, 0, '{}'::jsonb),
      (1, 'default', NULL, 'none', NULL, 1, 0, '{}'::jsonb);
EOSQL