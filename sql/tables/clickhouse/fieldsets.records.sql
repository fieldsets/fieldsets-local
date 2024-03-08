/**
 * Records Data Store
 * Should use tradional Columnar table.
 */
CREATE TABLE IF NOT EXISTS fieldsets.records (
    id		    UInt64,
    parent      UInt64,
    created     DateTime64(3) DEFAULT now64(3)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(created)
ORDER BY (parent, id, created)
SETTINGS index_granularity = 8192;
