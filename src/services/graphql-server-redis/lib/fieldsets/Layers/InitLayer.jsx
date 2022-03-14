import React, {Suspense} from 'react';
const Defaults = React.lazy(() => import('lib/fieldsets/Hooks/Handlers/Defaults'));
const Status = React.lazy(() => import('lib/fieldsets/Hooks/Handlers/Status'));
const Portals = React.lazy(() => import('lib/fieldsets/Hooks/Handlers/Portals'));

/**
 * Initialize a FieldSets Application and allow for customization of initialization.
 */
const InitLayer = (props) => {
  /**
   * While Defaults and status are hooks, they don't require access to the datacache.
   * Since they are used for initialization of the application, we call them outside of the hooks component and put them in their own component.
   */
  return (
    <React.StrictMode>
      <Suspense fallback={<h1>Initializing...</h1>}>
        <Status
          stage='application'
          status='default'
          message='Initializing FieldSets Application'
        >
          <Suspense fallback={<h1>Setting defaults...</h1>}>
            <Defaults>
              <Suspense fallback={<h1>Setting up portals...</h1>}>
                <Portals>
                  {props.children}
                </Portals>
              </Suspense>
            </Defaults>
          </Suspense>
        </Status>
      </Suspense>
    </React.StrictMode>
  );
};

export default InitLayer;
