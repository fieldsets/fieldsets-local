/**
 * Map Data Store
 * Partitioned on PostgreSQL side for performance.
 * Mappings are one to one key value pairs. Can be used to create key value parings such as Redis or a ClickHouse Dictionary.
 */
CREATE TABLE IF NOT EXISTS fieldsets.mappings(
    id              BIGINT NOT_NULL,
    set_id          BIGINT NOT NULL,
    field_id        BIGINT NOT NULL,
    fieldset_id     BIGINT_NOT_NULL
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated         TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (field_id)
TABLESPACE mappings;

CREATE TABLE IF NOT EXISTS fieldsets.__default_mappings PARTITION OF fieldsets.mappings DEFAULT TABLESPACE mappings;
