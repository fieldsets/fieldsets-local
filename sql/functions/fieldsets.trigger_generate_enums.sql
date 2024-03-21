/**
 * trigger_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends TRIGGER: trigger_31_generate_enums
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_generate_enums() RETURNS trigger AS $function$
  DECLARE
    insert_stmt TEXT := 'INSERT INTO fieldsets.enums(id,token,field_id,field_token) VALUES';
    sql_stmt TEXT := '';
    parent_record RECORD;
    auth_string TEXT;
  BEGIN
    SELECT id, token, parent, parent_token, field_id, field_token
    INTO parent_record
    FROM fieldsets.fieldsets
    WHERE
      type = 'enum'::FIELD_TYPE AND
      parent_token = NEW.parent_token;

    IF parent_record IS NOT NULL THEN
      sql_stmt := format('(%s,%L,%s,%L)', NEW.id, NEW.token, parent_record.field_id, parent_record.field_token);
      insert_stmt := format(E'%s\n%s,', insert_stmt, sql_stmt);
      insert_stmt := trim(TRAILING ',' FROM insert_stmt);
      EXECUTE insert_stmt;
    END IF;
    RETURN NEW;
  END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.trigger_generate_enums() IS
'/**
 * trigger_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends TRIGGER: trigger_31_generate_enums
 **/';