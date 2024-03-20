/**
 * trigger_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends TRIGGER: trigger_31_generate_enums
 **/
CREATE OR REPLACE FUNCTION fieldsets.trigger_generate_enums() RETURNS trigger AS $function$
  DECLARE
    sql_stmt TEXT;
  BEGIN
    sql_stmt := format('INSERT INTO fieldsets.enums(id,token,field_id,field_token) VALUES(%s,%L,%s,%L);', NEW.id, NEW.token, NEW.field_id, NEW.field_token);
    EXECUTE sql_stmt;
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fieldsets.trigger_generate_enums() IS
'/**
 * trigger_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends TRIGGER: trigger_31_generate_enums
 **/';