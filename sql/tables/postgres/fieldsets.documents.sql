/**
 * Documents Data Store
 * Use Postgresql with JSONB column.
 * @TODO: Integrate MongoDB Option
 */
CREATE TABLE IF NOT EXISTS fieldsets.documents (
    id          BIGINT NOT NULL,
    field_id    BIGINT NOT NULL,
    document    JSONB,
    created     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated     TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (field_id)
TABLESPACE documents;