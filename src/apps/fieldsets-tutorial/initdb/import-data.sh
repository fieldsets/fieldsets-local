#!/bin/bash

# This init script should be copied to fieldsets-local. A copy can be placed in ./config/fieldsets/initdb/

set -e

FILE=/fieldsets/fieldsets_mongo_tutorial.init
if [[ ! -f "$FILE" ]]; then


    if [ ! -z "$MONGO_USER" ]; then
        if [ ! -z "$MONGO_PASSWORD" ]; then
            echo "Using password authentication!"
            auth="--authenticationDatabase admin -u $MONGO_USER -p $MONGO_PASSWORD"
        fi
    fi

    cd /fieldsets/
    git clone https://github.com/fieldsets/mongodb-sample-datasets.git
    cd ./mongodb-sample-datasets

    # This loads all the data sets.
    if [ $MONGO_LOAD_SAMPLE_DATA -eq 1 ]; then
                for coll in *; do
                    if [ -d "${coll}" ] ; then
                        echo "$coll"
                        for file in $coll/*; do
                            CURRENT_COLLECTION="$(basename $file .json)"
                            mongoimport --drop --host $MONGO_HOST --port $MONGO_PORT --db "$coll" --collection "$(basename $file .json)" --file $file $auth

                            #psql -v --host "$POSTGRES_HOST" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
                            #    SET search_path TO 'documents';
                            #    CREATE FOREIGN TABLE IF NOT EXISTS documents.${CURRENT_COLLECTION} (
                            #        _id         BIGSERIAL,
                            #        id          BIGSERIAL,
                            #        fieldset_id	BIGINT NOT NULL,
                            #        document	JSONB NULL,
                            #        meta		JSONB NULL,
                            #        ts			TIMESTAMP NULL DEFAULT NOW(),
                            #        parsed		BOOLEAN DEFAULT FALSE
                            #    ) 
                            #    SERVER mongo_server OPTIONS (database '$coll', collection 'S{CURRENT_COLLECTION}');
                            #EOSQL

                            #echo "$(basename $file .json)"
                            #echo "$file"
                        done
                    fi
                done
            
    else
        mongoimport --drop --host $MONGO_HOST --port $MONGO_PORT --db "tutorial" --collection "companies" --file /fieldsets/mongodb-sample-datasets/sample_training/companies.json $auth
        mongoimport --drop --host $MONGO_HOST --port $MONGO_PORT --db "tutorial" --collection "tweets" --file /fieldsets/mongodb-sample-datasets/sample_training/tweets.json $auth
    fi

    touch "$FILE"
fi