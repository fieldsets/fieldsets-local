import React, { Suspense, useState, useCallback, useEffect, useTransition } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { useStatus, usePortals } from 'lib/fieldsets/Hooks';

const Container = React.lazy(() => import('lib/fieldsets/Containers/Container'));
const InterfaceType = React.lazy(() => import('./InterfaceType'));

/**
 * This is the generic Interface component which is used to build diagram containers.
 * This component initializes the data cache with diagram data, as well as setting up the underlying coordinate system for tracking diagram interactions.
 */
const Interface = ({id, name, type, meta, portal = 'interface', visible = false, children}) => {
  const stageName = 'render';
  const [{stage, status, complete}, updateStatus] = useStatus();
  const [loaded, updateLoaded] = useState(false);
  const portals = usePortals();

  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  // We use our controller context to trigger our rendering into our portal.
  useEffect(
    () => {
      if ('container' === stage && complete) {
        applyChange(() => {
          updateStatus('initializing', `Initializing diagram ${id}`, stageName);
          updateLoaded(true);
        });
      }
    },
    [stage, status, complete, id, applyChange, updateStatus]
  );

  const renderInterface = useCallback(
    () => {
      if (stageName === stage && visible && loaded && ! pending && portals && portals[portal] && portals[portal].portalRef ) {
        return(
          ReactDOM.createPortal(
            <InterfaceType
              id={id}
              name={name}
              type={type}
            >
              {children}
            </InterfaceType>,
            portals[portal].portalRef
          )
        );
      }
      return null;
    },
    [stage, visible, loaded, pending, portals,children, id, name, portal, type]
  );

  return(
    <React.Fragment>
      <Suspense fallback={<h1>{`loading ${portal} data ...`}</h1>}>
        <Container
          id={id}
          name={name}
          type={'interface'}
          view={type}
          meta={meta}
          visible={visible}
        >
          {renderInterface()}
        </Container>
      </Suspense>
      {children}
    </React.Fragment>
  );
}

Interface.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  type: PropTypes.string.isRequired,
  meta: PropTypes.object,
  visible: PropTypes.bool,
  children: PropTypes.node
};

export default Interface;
