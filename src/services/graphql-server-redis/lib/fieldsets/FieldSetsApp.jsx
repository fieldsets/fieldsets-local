import React from 'react';
import { InitLayer, DataLayer, VisualLayer } from 'lib/fieldsets';
/**
 * Initialize a FieldSets Application and allow for customization of initialization.
 */
const FieldSetsApp = (props) => {
  /**
   * While Defaults and status are hooks, they don't require access to the datacache.
   * Since they are used for initialization of the application, we call them outside of the hooks component and put them in their own component.
   */
  return (
    <InitLayer>
      <DataLayer>
        <VisualLayer>
          {props.children}
        </VisualLayer>
      </DataLayer>
    </InitLayer>

  );
};

export default FieldSetsApp;
