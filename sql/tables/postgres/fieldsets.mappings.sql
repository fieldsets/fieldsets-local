/**
 * Lookup Data Store
 * Partitioned on PostgreSQL side for performance.
 * Lookups are one to one key value pairs. Can be used to create key value parings such as Redis or a ClickHouse Dictionary.
 */
CREATE TABLE IF NOT EXISTS fieldsets.lookups(
    id              BIGINT NOT NULL,
    set_id          BIGINT NOT NULL,
    field_id        BIGINT NOT NULL,
    fieldset_id     BIGINT NOT NULL,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated         TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (field_id)
TABLESPACE lookups;

CREATE TABLE IF NOT EXISTS fieldsets.__default_lookups PARTITION OF fieldsets.lookups DEFAULT TABLESPACE lookups;
