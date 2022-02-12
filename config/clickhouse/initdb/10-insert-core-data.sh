#!/bin/bash
set -e

# Insert Config
#psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#  INSERT INTO public.config (id, token, description, value, meta)
#  	VALUES
#  	  (0, 'fieldsets-version', 'Fieldsets Version', '0.0.1', '{}'::jsonb),
#		  (1, 'fieldsets-init-date', 'Fieldsets Init Date', now(), '{}'::jsonb),
#		  (2, 'fieldsets-last-update', 'Fieldsets Init Date', 'none', '{}'::jsonb),
#      (100, 'postgres-major-version', 'PostgreSQL Major Version', '${POSTGRES_VERSION}', '{}'::jsonb),
#		  (101, 'postgres-version', 'PostgreSQL version', version(), '{}'::jsonb);
#EOSQL