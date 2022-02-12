#!/bin/bash
set -e

# The records table is a time series record of values. These records are partitioned by field_id to make data aggregation more performant.
clickhouse-client --host 127.0.0.1 --user $CLICKHOUSE_USER --password $CLICKHOUSE_PASSWORD --database $CLICKHOUSE_DB -n <<-EOSQL
CREATE TABLE IF NOT EXISTS $CLICKHOUSE_DB.records
(
    fieldset_id UInt64,
    field_id UInt64,
    value Tuple(
        string Nullable(String),
        number Nullable(Int64),
        decimal Nullable(Float64),
        currency Nullable(Decimal32(4)),
        object Array(Nullable(String)),
        list Array(Nullable(String)),
        bool Nullable(Boolean),
        date Nullable(Date),
        ts Nullable(DateTime)
    ),
    position Int64 DEFAULT 0,
    ts DateTime DEFAULT NOW() Codec(DoubleDelta, LZ4)
)
ENGINE = ReplacingMergeTree()
PARTITION BY (field_id, toYear(ts))
ORDER BY (fieldset_id, ts, position)
SETTINGS index_granularity = 8192;
EOSQL

# Sequences are position oriented data that needs to be partitioned by the fieldset itself.
# Typically sequences only contain 1 field type (but not limited to) and utilize fieldsets to distinguish the difference between sequences.
clickhouse-client --host 127.0.0.1 --user $CLICKHOUSE_USER --password $CLICKHOUSE_PASSWORD --database $CLICKHOUSE_DB -n <<-EOSQL
CREATE TABLE IF NOT EXISTS $CLICKHOUSE_DB.sequences
(
    fieldset_id UInt64,
    field_id UInt64,
    value Tuple(
        string Nullable(String),
        number Nullable(Int64),
        decimal Nullable(Float64),
        currency Nullable(Decimal32(4)),
        object Array(Nullable(String)),
        list Array(Nullable(String)),
        bool Nullable(Boolean),
        date Nullable(Date),
        ts Nullable(DateTime)
    ),
    position Int64 DEFAULT 0
)
ENGINE = ReplacingMergeTree()
PARTITION BY (position, field_id)
ORDER BY (fieldset_id, position)
SETTINGS index_granularity = 8192;
EOSQL



