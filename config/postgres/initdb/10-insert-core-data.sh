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
  INSERT INTO $POSTGRES_DB.sets (id, token, label, description, parent, meta)
  VALUES
    (0,'set','Set','An abstract set',0,'{}'::jsonb);
EOSQL

# Insert Fields
# field_value composite data type is of format:
#(
#   "string"		  TEXT, # ex: 'something'
#		"number"		  BIGINT, # ex: 0
#		"decimal"		  DECIMAL, # ex: 0.0
#		"object"		  JSONB, # ex: '{"key":"value"}'::jsonb
#		"list" 			  TEXT[], # ex: '{1,2,3}'
#		"bool" 			  BOOLEAN, # ex: FALSE
#		"date" 			  DATE, # ex: NOW::date
#		"ts"	        TIMESTAMP, # ex: NOW()
#)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  INSERT INTO $POSTGRES_DB.fields (id, token, label, description, primary_set, type, default_value, default_position, parent, meta)
  VALUES
    (0, 'field', 'Field', 'An abstract text field', 0, 'string', NULL, 0, 0, '{}'::jsonb);
EOSQL
