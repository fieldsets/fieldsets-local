/**
 * Filters Data Store
 * Should use tradional RDBMS table.
 */
CREATE TABLE IF NOT EXISTS fieldsets.filters (
    id              BIGINT NOT NULL,
    parent          BIGINT NOT NULL,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)  PARTITION BY LIST (parent)
TABLESPACE filters;

-- Default partition if not defined.
CREATE TABLE IF NOT EXISTS fieldsets.__default_filter PARTITION OF fieldsets.filters DEFAULT TABLESPACE filters;

