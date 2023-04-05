/**
 * trigger_create_set_partitions: triggered after a set is defined. Create a new data table partition.
 * @depends TRIGGER: create_set_partitions
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_create_set_partitions() RETURNS trigger AS $function$
  DECLARE
    --db_schema TEXT := TG_ARGV[0];
    --parent_table_name TEXT := TG_ARGV[1];
    --partition_tablespace TEXT := TG_ARGV[2];
    create_tbl_sql TEXT;
    cron_job_token TEXT;
    cron_job_sql TEXT;
    partition_set_id BIGINT;
    partition_table_name TEXT;
    partition_tablespace TEXT := 'fieldsets';
    parent_table_name TEXT := TG_TABLE_NAME;
  BEGIN 

    /*
      id         	BIGINT NOT NULL,
      token     	VARCHAR(255) NOT NULL,
      label      	TEXT NULL,
      parent     	BIGINT NULL DEFAULT 0,
      meta  		JSONB NULL
    */
    SELECT NEW.parent INTO partition_set_id;
    
    IF public.tablespace_exists(parent_table_name) THEN
      partition_tablespace := parent_table_name;
    END IF;

    partition_table_name := format('__%s_%s_%s', parent_table_name, partition_year, partition_month);
    BEGIN
  	  create_tbl_sql := format('CREATE TABLE %I.%I (LIKE %I.%I INCLUDING ALL) TABLESPACE %I;', db_schema, partition_table_name, db_schema, parent_table_name, partition_tablespace);
      EXECUTE create_tbl_sql;
      
      -- Asynchronously attach partition with scheduled cronjob.
      cron_job_token := format('attach_partition%s', partition_table_name);
      cron_job_sql := format('CALL public.attach_date_partition(%L,%L,%L,%L,%L);', db_schema, parent_table_name, partition_table_name, partition_year, partition_month);
      EXECUTE format('SELECT cron.schedule(%L, %L, %L);', cron_job_token, '* * * * *', cron_job_sql);
    EXCEPTION WHEN duplicate_table THEN
      NULL;
    END;
    
    RETURN NEW;
  END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.trigger_create_set_partitions() IS 
'/**
 * trigger_create_new_date_partition: triggered before insert into data_values. Create a new data table if doesn''t exist and notify parent table to attach as partition.
 * @depends TRIGGER: create_new_date_partition
 **/';