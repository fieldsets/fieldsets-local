#!/bin/bash
set -e

# Insert Config
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO fieldsets.sets (id, token, label, description, parent, meta)
    VALUES
        (100000, 'user', 'User', 'Basic user fields', 0, '{}'::jsonb);
   
    INSERT INTO fieldsets.fields (id, token, label, description, prmary_set, type, default_value, default_position, parent, meta)
    VALUES
        (100000, 'username', 'Username', 'A username or login name', 100000, '{}'::jsonb),
        (100001, 'email', 'Email Address', 'Email address of the user', 100000, '{}'::jsonb),
        (100002, 'firstname', 'First Name', 'Frist name of the user', 100000, '{}'::jsonb),
        (100003, 'lastname', 'Last Nname', 'Last name of the user', 100000, '{}'::jsonb),
        (100004, 'displayname', 'Display Name', 'Name to display or full name', 100000, '{}'::jsonb);
   
INSERT INTO fieldsets.fieldsets (id, token, type, store, source, set_id, parent, meta)
    VALUES
        (100000, 'user-profile', 'user', 'profile', NULL, 100000, 0, '{}'::jsonb);
EOSQL
