/**
 * create_set_partitions: triggered on insert into sets table. Create a new partition for set.
 * @depends trigger_create_set_partitions FUNCTION (postgresql)
 **/
/**
DROP TRIGGER IF EXISTS create_set_partitions ON fieldsets.sets;
CREATE TRIGGER create_set_partitions
AFTER INSERT ON fieldsets.sets
FOR EACH ROW 
EXECUTE FUNCTION trigger_create_set_partitions();
*/