#!/bin/bash
set -e

docker exec -it fieldsets /usr/bin/mongosh --host fieldsets-mongo --username fieldsets --password fieldsets --port 27017 --authenticationDatabase admin
