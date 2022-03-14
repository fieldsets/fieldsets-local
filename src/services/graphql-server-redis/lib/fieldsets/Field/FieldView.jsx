import * as FieldViews from './Views';
import * as CustomFieldViews from 'components/Fields';
import { useInputEvents, useClickEvents } from 'lib/fieldsets/Hooks';

const FieldView = (props) => {
  const [handleOnChange] = useInputEvents(props.onChange);
  const [handleClick, handleDoubleClick] = useClickEvents(props.onClick, props.onDoubleClick);

  let events = {};
  if ( props.onDoubleClick ) {
    events.onDoubleClick = handleDoubleClick;
  }

  if ( props.onChange ) {
    events.onChange = handleOnChange;
  }

  if ( props.onClick ) {
    events.onClick = handleClick;
  }

  if (props.view) {
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const viewClassName = props.view.charAt(0).toUpperCase() + props.view.slice(1);
    if ( viewClassName in CustomFieldViews ) {
      return CustomFieldViews[viewClassName]({...props, events});
    } else if ( viewClassName in FieldViews ) {
      return FieldViews[viewClassName]({...props, events});
    }
  }

  return FieldViews['Default']({...props, events});
}

export default FieldView;
