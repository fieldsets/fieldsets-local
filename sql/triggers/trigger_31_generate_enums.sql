/**
 * trigger_31_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends FUNCTION: trigger_generate_enums
 **/
CREATE OR REPLACE TRIGGER trigger_31_generate_enums
AFTER INSERT ON fieldsets.fieldsets
FOR EACH ROW
WHEN (NEW.type = 'enum'::FIELD_TYPE AND NEW.field_token <> NEW.token AND NEW.store = 'fieldset'::STORE_TYPE)
EXECUTE FUNCTION fieldsets.trigger_generate_enums();

COMMENT ON TRIGGER trigger_31_generate_enums ON fieldsets.fieldsets IS
'/**
 * trigger_31_generate_enums: triggered after insert into fieldsets table. Calculate enumerated values from fieldsets.
 * @depends FUNCTION: trigger_generate_enums
 * @priority 31
 */';