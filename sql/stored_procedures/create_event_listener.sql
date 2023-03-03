/**
 * create_event_listener: A scheduled event check. Runs at a set interval for fieldsets events and routes all pending events of a given pipeline to an event handler.
 * @param TEXT: pipeline_token - The event pipeline token.
 **/
CREATE OR REPLACE PROCEDURE cron.create_event_listener(pipeline_token TEXT) AS $procedure$
    DECLARE
        cron_job_sql TEXT;
        cron_job_token TEXT;
        cron_job_schedule TEXT := '* * * * *';
        event_handler TEXT;
    BEGIN
        cron_job_token := format('%s_event_listener', pipeline_token);
        
        -- Customize event handlers here. Adding custom handlers to specific pipeline schema will help with code maintainence.
        -- You can customize the schedule and next status as well.
        CASE pipeline_token
            WHEN 'fieldsets' THEN
                event_handler := format('CALL fieldsets.process_event(%L);', pipeline_token);
            ELSE
                event_handler := format('CALL pipeline.process_event(%L);', pipeline_token);
        END CASE;

        cron_job_sql := format('SELECT cron.schedule(%L, %L, %L);', cron_job_token, cron_job_schedule, event_handler);
        EXECUTE cron_job_sql;
    END;
$procedure$ LANGUAGE plpgsql;

COMMENT ON PROCEDURE cron.create_event_listener (TEXT) IS 
'/**
 * create_event_listener: A scheduled event check. Runs at a set interval for fieldsets events and routes all pending events of a given pipeline to an event handler.
 * @param TEXT: pipeline_token - The event pipeline token.
 **/';