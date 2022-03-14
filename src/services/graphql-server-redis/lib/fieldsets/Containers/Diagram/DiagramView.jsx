import * as DiagramViews from 'containers/Diagrams';
import { useContainer } from 'lib/fieldsets/Hooks';

const DiagramView = (props) => {
  const containerData = useContainer();
  if (props.view) {
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const viewClassName = props.view.charAt(0).toUpperCase() + props.view.slice(1);
    if (viewClassName in DiagramViews ) {
      return DiagramViews[viewClassName]({...props, data: [...containerData.fieldsets], meta: {...containerData.meta}});
    }
  }

  return null;
}

export default DiagramView;
