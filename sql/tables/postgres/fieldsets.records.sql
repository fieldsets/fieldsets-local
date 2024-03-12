/**
 * Records Data Store
 * Should use tradional Columnar table.
 */

CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.records(
    id         	    BIGINT NOT NULL,
    parent     	    BIGINT NULL DEFAULT 0,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
SERVER clickhouse_server;
