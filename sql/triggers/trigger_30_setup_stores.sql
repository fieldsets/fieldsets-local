/**
 * trigger_30_setup_stores: triggered after insert into fieldsets table. Create a new data partition for the new id.
 * @depends trigger_setup_stores FUNCTION (postgresql)
 **/
DROP TRIGGER IF EXISTS trigger_30_setup_stores ON fieldsets.fieldsets;
CREATE TRIGGER trigger_30_setup_stores
AFTER INSERT ON fieldsets.fieldsets
REFERENCING NEW TABLE AS new_fieldsets
FOR EACH STATEMENT
EXECUTE FUNCTION fieldsets.trigger_setup_stores();

COMMENT ON TRIGGER trigger_30_setup_stores ON fieldsets.fieldsets IS
'/**
 * trigger_30_setup_stores: triggered after insert into fieldsets table. Create a new data partition for the new id.
 * @depends trigger_setup_stores FUNCTION (postgresql)
 * @priority 30
 */';