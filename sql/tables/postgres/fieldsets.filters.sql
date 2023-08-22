/**
 * Filters Data Store
 * Should use tradional RDBMS table.
 */
CREATE TABLE IF NOT EXISTS fieldsets.filters (
    id          BIGINT NOT NULL,
    parent      BIGINT NOT NULL,
    set_id      BIGINT NOT NULL,
    set_parent  BIGINT NOT NULL,
    value       FIELD_VALUE,
    created     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated     TIMESTAMPTZ NOT NULL DEFAULT NOW()
) TABLESPACE filters;