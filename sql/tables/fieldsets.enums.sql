/**
 * Storage of enumerated fields
 * Uses Clickhouse Low-Cardinality Data Type.
 * This removes the need to declare 
 */
CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.enums(
    id         	    BIGINT NOT NULL,
    token           TEXT NOT NULL,
    field_id        BIGINT NULL DEFAULT 0,
    field_token     TEXT NOT NULL
)
SERVER clickhouse_server;

