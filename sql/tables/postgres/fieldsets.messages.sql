/**
* Messages Data Store
* Uses Clickhouse Log Table Engine. Could also use unlogged PostreSQL data table with no indexes fast write performance.
*/
CREATE FOREIGN TABLE IF NOT EXISTS fieldsets.messages(
    id         	    BIGINT NOT NULL,
    parent     	    BIGINT NULL DEFAULT 0,
    set_id          BIGINT NULL,
    set_parent      BIGINT NULL,
    message         TEXT NULL,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
SERVER clickhouse_server;
