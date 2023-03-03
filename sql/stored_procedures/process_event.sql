/**
 * process_event: A scheduled event check. Runs at a set interval for pending fieldsets events, performs the defined event handler and updates the status.
 * @param TEXT: pipeline_token - The event pipeline token.
 **/
CREATE OR REPLACE PROCEDURE pipeline.process_event(pipeline_token TEXT) AS $procedure$
    DECLARE
        event_record RECORD;
        listen_for_status pipeline.FIELDSETS_EVENT_STATUS := 'pending';
        new_event_status pipeline.FIELDSETS_EVENT_STATUS := 'undefined';
        update_status_sql TEXT;
    BEGIN
        FOR event_record IN 
            SELECT 
                e.event_id,
                e.pipeline,
                e.event_token,
                e.meta_data,
                e.event_status
            FROM pipeline.events e
            WHERE e.pipeline = pipeline_token
                AND e.event_status = listen_for_status
        LOOP
            CASE pipeline_token
   		        WHEN 'local' THEN
                    CASE event_record.event_token
                        WHEN 'fieldsets-local-container-init' THEN
                            new_event_status := 'complete';
                        ELSE
                            new_event_status := 'undefined';
                    END CASE;
                ELSE
                    new_event_status := 'undefined';
            END CASE;
            update_status_sql := format('UPDATE pipeline.events SET event_status = %L WHERE event_id = %L;', new_event_status, event_record.event_id);
            EXECUTE update_status_sql;
        END LOOP;
    END;
$procedure$ LANGUAGE plpgsql;

COMMENT ON PROCEDURE pipeline.process_event (TEXT) IS 
'/**
 * process_event: A scheduled event check. Runs at a set interval for pending fieldsets events, performs the defined event handler and updates the status.
 * @param TEXT: pipeline_token - The event pipeline token.
 **/';