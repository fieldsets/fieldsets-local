/**
 * Filters Data Store
 * Should use tradional RDBMS table.
 */
CREATE TABLE IF NOT EXISTS fieldsets.filters (
    id              BIGINT NOT NULL,
    type            FIELD_TYPE NOT NULL,
    field_id        BIGINT NOT NULL, -- UNIQUE
    value           FIELD_VALUE,
    created         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated         TIMESTAMPTZ NOT NULL DEFAULT NOW()
)  PARTITION BY LIST (type)
TABLESPACE filters;

-- Filter Partitions by type

-- fieldset
CREATE TABLE IF NOT EXISTS fieldsets.__fieldset_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('fieldset')
    TABLESPACE fieldsets;

-- string
CREATE TABLE IF NOT EXISTS fieldsets.__string_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('string')
    TABLESPACE fieldsets;

-- number
CREATE TABLE IF NOT EXISTS fieldsets.__number_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('number')
    TABLESPACE fieldsets;

-- decimal
CREATE TABLE IF NOT EXISTS fieldsets.__decimal_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('decimal')
    TABLESPACE fieldsets;

-- object
CREATE TABLE IF NOT EXISTS fieldsets.__object_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('object')
    TABLESPACE fieldsets;

-- list
CREATE TABLE IF NOT EXISTS fieldsets.__list_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('list')
    TABLESPACE fieldsets;

-- array
CREATE TABLE IF NOT EXISTS fieldsets.__array_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('array')
    TABLESPACE fieldsets;

-- vector
CREATE TABLE IF NOT EXISTS fieldsets.__vector_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('vector')
    TABLESPACE fieldsets;

-- bool
CREATE TABLE IF NOT EXISTS fieldsets.__bool_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('bool')
    TABLESPACE fieldsets;

-- date
CREATE TABLE IF NOT EXISTS fieldsets.__date_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('date')
    TABLESPACE fieldsets;

-- ts
CREATE TABLE IF NOT EXISTS fieldsets.__ts_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('ts')
    TABLESPACE fieldsets;

-- search
CREATE TABLE IF NOT EXISTS fieldsets.__search_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('search')
    TABLESPACE fieldsets;

-- uuid
CREATE TABLE IF NOT EXISTS fieldsets.__uuid_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('uuid')
    TABLESPACE fieldsets;

-- function
CREATE TABLE IF NOT EXISTS fieldsets.__function_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('function')
    TABLESPACE fieldsets;

-- custom
CREATE TABLE IF NOT EXISTS fieldsets.__custom_filter PARTITION OF fieldsets.filters
    FOR VALUES IN ('custom')
    TABLESPACE fieldsets;

-- Default data storage if not defined.
CREATE TABLE IF NOT EXISTS fieldsets.__default_filter PARTITION OF fieldsets.filters DEFAULT TABLESPACE fieldsets;

