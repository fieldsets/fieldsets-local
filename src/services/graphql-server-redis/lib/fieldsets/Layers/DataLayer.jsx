import React, {Suspense} from 'react';
const DataCache = React.lazy(() => import('lib/fieldsets/DataCache/DataCache'));
const Hooks = React.lazy(() => import('lib/fieldsets/Hooks/Hooks'));

/**
 * A FieldSets Web Application, whcih should be nested within the FieldSetsInit component.
 * This is a wrapper component that sets data cache and the correct component ordering for prop drilling.
 */
const FieldSetsApp = (props) => {
  return (
    <Suspense fallback={<h1>Loading datacache...</h1>}>
      <DataCache>
        <Suspense fallback={<h1>Loading hooks...</h1>}>
          <Hooks>
            {props.children}
          </Hooks>
        </Suspense>
      </DataCache>
    </Suspense>
  );
};

export default FieldSetsApp;
