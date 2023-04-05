/**
 * Map Data Store
 * Partitioned on PostgreSQL side for performance. Can be used to create key value parings such as Redis or a ClickHouse Dictionary.
 */
CREATE TABLE IF NOT EXISTS fieldsets.mappings(
    set_id          BIGINT NOT NULL,
    set_parent      BIGINT NOT NULL DEFAULT 0,
    field_id        BIGINT NOT NULL DEFAULT 0,
    field_parent    BIGINT NOT NULL DEFAULT 0,
    field_type      field_type NULL DEFAULT 'string'::field_type,
    map_value       field_value NULL,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated         TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (set_parent)
TABLESPACE mappings;

CREATE TABLE IF NOT EXISTS fieldsets.__default_mappings PARTITION OF fieldsets.mappings DEFAULT TABLESPACE mappings;

