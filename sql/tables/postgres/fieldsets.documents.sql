/**
 * Documents Data Store
 * Use Postgresql with JSONB column.
 * @TODO: Integrate MongoDB Option
 */
CREATE TABLE IF NOT EXISTS fieldsets.documents (
    id          BIGINT NOT NULL,
    parent      BIGINT NOT NULL,
    document    JSONB,
    created     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated     TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (parent)
TABLESPACE documents;

-- Default partition if not defined.
CREATE TABLE IF NOT EXISTS fieldsets.__default_document PARTITION OF fieldsets.documents DEFAULT TABLESPACE documents;