#!/bin/bash
set -e


# Import schema from mongo
collections=$(docker exec -it fieldsets /usr/bin/mongosh --norc --quiet --username fieldsets --password fieldsets --authenticationDatabase admin --eval "EJSON.stringify(db.getCollectionNames());" "mongodb://fieldsets-mongo:27017/fieldsets")

echo "${collections}" | jq -c '.[]'