#!/bin/bash
set -e

# Create our data tables and relational architecture.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE OR REPLACE FUNCTION fieldsets.add_fieldset()
    RETURNS trigger
    LANGUAGE plpgsql
    AS \$function\$
        DECLARE
            token_name TEXT;
            fieldset_id BIGINT;
            set_id BIGINT;
        BEGIN
            IF NEW.store = 'profile' THEN
                fieldset_id := NEW.id;
                token_name := NEW.token;
                set_id := NEW.set_id;
                EXECUTE fieldsets.create_profile_partition(fieldset_id, token_name);
                EXECUTE fieldsets.create_profile_dictionary(set_id, token_name);
            END IF;

            RETURN NEW;
        END;
    \$function\$
    ;
EOSQL


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE TRIGGER add_fieldset_trigger
	    AFTER INSERT
	    ON fieldsets.fieldsets
	    FOR EACH ROW
		    EXECUTE PROCEDURE fieldsets.add_fieldset();
EOSQL


#        ELSIF NEW.store = 'document' THEN
#        ELSIF NEW.store = 'record' THEN
#        ELSIF NEW.store = 'sequence' THEN
#        ELSIF NEW.store = 'connection' THEN
#        ELSIF NEW.store = 'message' THEN
#        ELSIF NEW.store = 'text' THEN