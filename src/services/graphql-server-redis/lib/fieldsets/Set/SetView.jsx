import * as Views from 'components/Sets';

const SetView = (props,ref) => {
  if (props.view) {
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const viewClassName = props.view.charAt(0).toUpperCase() + props.view.slice(1);
    return Views[viewClassName](props,ref);
  }
  return null;
}

export default SetView;
