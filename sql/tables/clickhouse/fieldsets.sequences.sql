/**
 * Position Data Store
 * Should use tradional Columnar table.
 */
/*
CREATE TABLE IF NOT EXISTS fieldsets.sequences (
    id		    UInt64,
    parent      UInt64,
    position    Int64
)
ENGINE = MergeTree()
PARTITION BY position
ORDER BY (parent, id, position);
*/