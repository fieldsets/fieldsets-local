import React, {Suspense} from 'react';
const Controller = React.lazy(() => import('lib/fieldsets/Containers/Controller'));
/**
 * This layer manages container visualization and interactions with it.
 */
const VisualLayer = (props) => {
  return (
    <Suspense fallback={<h1>Initializing controller...</h1>}>
      <Controller>
        {props.children}
      </Controller>
    </Suspense>
  );
};

export default VisualLayer;
