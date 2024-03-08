/**
 * Lookup Data Store
 * Partitioned on PostgreSQL side for performance.
 * Lookups associate a given fieldset id with another.
 */
CREATE TABLE IF NOT EXISTS fieldsets.lookups(
    id              BIGINT NOT NULL,
    parent          BIGINT NOT NULL,
    field_id        BIGINT NOT NULL,
    lookup_id       BIGINT NOT NULL
) PARTITION BY LIST (parent)
TABLESPACE lookups;
-- partition by parent, field_id

CREATE TABLE IF NOT EXISTS fieldsets.__default_lookups PARTITION OF fieldsets.lookups DEFAULT TABLESPACE lookups;

