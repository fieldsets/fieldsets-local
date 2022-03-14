# Layers
This directory contains top level components used to define various layers of a FieldSets application. Currently there are three layers.

* Initialization layer. At this layer you can overwrite and add any data defaults for your specific application.
* Data Layer. This layer sets up priming of a data set for visualization and provides access to the multiple data stores used in the application.
* Visualization Layer. This layer is the layer you will create in your application using the containers defined in the FieldSets core library.

We package the first two layers in the `FieldSetsApp` component, but if you want more control over the default data values, you can use the `DataLayer` and `InitLayer` and `VisualLayer` components individually.

```
import {useDefaults, useStatus} from 'lib/fieldsets/Hooks';

const MyDefaults = (props) => {
  const [defaults, updateDefaults] = useDefaults();
  const [{stage, status, message}, updateStatus] = updateStatus();

  useEffect(
    () => {
      if ('defaults' === stage && 'initializing' === 'status') {
        // DO SOMETHING CUSTOM
        const custom = {};
        // This will merge with current defaults, to overwrite pass a second argument of true to `updateDefaults`.
        updateDefaults( custom );
      }
    },
    []
  );

  return(
    <React.Fragment>
      {props.children}
    </React.Fragment>
  );
}

const MyApp = (props) => {
  return(
    <InitLayer>
      <MyDefaults>
        <DataLayer>
          <VisualLayer>
            {props.children}
          </VisualLayer>
        </DataLayer>
      </MyDefaults>
    </InitLayer>
  );
}
```
