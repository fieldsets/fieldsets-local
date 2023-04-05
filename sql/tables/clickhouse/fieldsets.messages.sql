/**
* Messages Data Store
* Uses Clickhouse Log Table Engine. Could also use unlogged PostreSQL data table with no indexes fast write performance.
*/
CREATE TABLE IF NOT EXISTS fieldsets.messages (
    id		    UInt64,
    parent      UInt64,
    set_id      UInt64,
    set_parent  UInt64,
    message     Text,
    created     DateTime64(3) DEFAULT now64(3)
)
ENGINE = Log();
