/**
 * get_field_data_type: Input a data value and the corresponding FIELD_TYPE and return the SQL representation of its FIELD_VALUE.
 * @param TEXT: field_type
 * @param TEXT: engine (clickhouse, postgresql)
 * @return ANY: BIGINT,TEXT,BIGINT,DECIMAL,JSONB,TEXT[],DECIMAL[],JSONB[],BOOLEAN,DATE,TIMESTAMP,TSVECTOR,UUID,JSONB,TEXT,JSONB,JSONB
 **/
CREATE OR REPLACE FUNCTION fieldsets.get_field_data_type(field_type TEXT, engine TEXT = 'postgres')
RETURNS TEXT
AS $function$
    BEGIN
        CASE field_type
            WHEN 'fieldset' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'UInt64';
                ELSE
                    RETURN 'BIGINT';
                END IF;
            WHEN 'string' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'TEXT';
                END IF;
            WHEN 'number' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Int64';
                ELSE
                    RETURN 'BIGINT';
                END IF;
            WHEN 'decimal' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Decimal';
                ELSE
                    RETURN 'DECIMAL';
                END IF;
            WHEN 'object' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'JSONB';
                END IF;
            WHEN 'list' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Array(Nullable(String))';
                ELSE
                    RETURN 'TEXT[]';
                END IF;
            WHEN 'array' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Array(Nullable(Decimal))';
                ELSE
                    RETURN 'DECIMAL[]';
                END IF;
            WHEN 'vector' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Array(Nullable(String))';
                ELSE
                    RETURN 'JSONB[]';
                END IF;
            WHEN 'bool' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Boolean';
                ELSE
                    RETURN 'BOOLEAN';
                END IF;
            WHEN 'date' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'Date';
                ELSE
                    RETURN 'DATE';
                END IF;
            WHEN 'ts' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'DateTime';
                ELSE
                    RETURN 'TIMESTAMP';
                END IF;
            WHEN 'search' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'TSVECTOR';
                END IF;
            WHEN 'uuid' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'UUID';
                ELSE
                    RETURN 'UUID';
                END IF;
            WHEN 'function' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'JSONB';
                END IF;
            WHEN 'enum' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'TEXT';
                END IF;
            WHEN 'custom' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'JSONB';
                END IF;
            WHEN 'any' THEN
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'JSONB';
                END IF;
            ELSE
                IF engine = 'clickhouse' THEN
                    RETURN 'String';
                ELSE
                    RETURN 'TEXT';
                END IF;
        END CASE;
    END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.get_field_data_type(TEXT,TEXT) IS
'/**
 * get_field_data_type: Input a data value and the corresponding FIELD_TYPE and return the SQL representation of its FIELD_VALUE.
 * @param TEXT: field_type
 * @param TEXT: engine (clickhouse, postgresql)
 * @return ANY: BIGINT,TEXT,BIGINT,DECIMAL,JSONB,TEXT[],DECIMAL[],JSONB[],BOOLEAN,DATE,TIMESTAMP,TSVECTOR,UUID,JSONB,TEXT,JSONB,JSONB
 **/';
