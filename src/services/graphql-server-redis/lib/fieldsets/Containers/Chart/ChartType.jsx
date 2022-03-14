import * as DiagramTypes from './Types';
import { useContainer } from 'lib/fieldsets/Hooks';

const DiagramType = (props) => {
  const getContainerData = useContainer();
  if (props.type) {
    const containerData = getContainerData();
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const typeClassName = props.type.charAt(0).toUpperCase() + props.type.slice(1);
    if (typeClassName in DiagramTypes ) {
      return DiagramTypes[typeClassName]({...props, data: [...containerData.fieldsets], meta: {...containerData.meta} });
    }
  }

  return null;
}

export default DiagramType;
