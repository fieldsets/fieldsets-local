#!/bin/bash
set -e

mongosh --host ${MONGO_HOST} --username ${MONGO_USER} --password ${MONGO_PASSWORD} --port ${MONGO_PORT} --authenticationDatabase admin <<EOF
    use ${MONGO_DB}
    db.createCollection("documents")
EOF