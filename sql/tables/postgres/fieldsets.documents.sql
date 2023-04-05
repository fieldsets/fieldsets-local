/**
 * Documents Data Store
 * Use Postgresql with JSONB column.
 * @TODO: Integrate MongoDB Option
 */
CREATE TABLE IF NOT EXISTS fieldsets.documents (
    id          BIGINT NOT NULL,
    parent      BIGINT NOT NULL,
    set_id      BIGINT NOT NULL,
    set_parent  BIGINT NOT NULL,
    document    JSONB,
    created     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated     TIMESTAMPTZ NOT NULL DEFAULT NOW()
) TABLESPACE documents;