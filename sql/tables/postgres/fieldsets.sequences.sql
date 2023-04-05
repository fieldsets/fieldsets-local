/**
 * Position Data Store
 * Should use tradional Columnar table.
 */
CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.sequences(
    id         	    BIGINT NOT NULL,
    parent     	    BIGINT NULL DEFAULT 0,
    set_id          BIGINT NULL,
    set_parent      BIGINT NULL,
    position        BIGINT NULL
)
SERVER clickhouse_server;
