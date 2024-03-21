/**
 * Storage of enumerated fields
 * Uses Clickhouse Low-Cardinality Data Type.
 * This removes the need to declare POSTGRES native ENUM data types for every field added.
 */
CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.enums(
    id         	    BIGINT NOT NULL,
    token           TEXT NOT NULL,
    field_id        BIGINT NULL DEFAULT 0,
    field_token     TEXT NOT NULL,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
SERVER clickhouse_server;

