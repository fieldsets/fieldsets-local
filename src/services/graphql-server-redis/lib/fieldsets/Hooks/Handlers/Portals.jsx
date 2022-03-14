import React, {
  createContext,
  useState,
  useLayoutEffect,
  useEffect,
  useCallback,
  useRef,
  forwardRef,
  useTransition
} from 'react';
import PropTypes from 'prop-types';
import { useStatus, useDefaults} from 'lib/fieldsets/Hooks';

export const PortalContext = createContext({});

export const Portal = forwardRef(({id, type, view, children}, ref) => {
  const portalRef = useRef(ref);
  const [defaults, updateDefaults] = useDefaults();

  useLayoutEffect(
    () => {
      if (type && defaults.portals[type]) {
        const updated = {...defaults};
        updated.portals[type].portalRef = portalRef.current;
        updateDefaults({...updated});
      }
    },
    []
  );

  const renderView = useCallback(
    () => {
      if (view) {
        return(
          <React.Fragment>
            {view}
          </React.Fragment>
        );
      } else {
        return (
          <React.Fragment>
            {children}
          </React.Fragment>
        );
      }
    },
    [view]
  );

  return (
    <div
      id={`${type}-portal`}
      className='fieldsets-portal'
      ref={portalRef}
    >
      {renderView()}
    </div>
  );
});

/**
 * Portals allow us to asyncronously load data for the aplication and load only the necessary interfaces once they are ready.
 * We can utilize status to trigger rendering of all sub components with portals.
 * This Portal handler defines what portals exist and their current status. Each portal represent a stage of the overall application lifecycle.
 */
const Portals = (props) => {
  // Portals are rendered after the 'defaults' lifcyle stage completes.
  const stageName = 'defaults';
  const [portals, updatePortals] = useState(false);
  const [defaults, updateDefaults] = useDefaults();
  const [current] = useStatus();
  const [{stage, status, message, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});

  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  const interfaceRef = useRef(null);
  const controllerRef = useRef(null);

  useEffect(
    () => {
      if (stageName === current.stage) {
        applyChange( () => {
          setStatus({...current});
        });
      }
    },
    [current]
  );

  /**
   * Add core portals to default list.
   */
  useEffect(
    () => {
      if ( stageName === stage && 'initializing' === status && ! pending && ! complete) {
        applyChange( () => {
          // These are our core portals.
          // Portals should contain references to their container elements, which we set on rendering.
          // Adding a custom portal, only requires an id.
          // We use portals here for interfaces.
          updateDefaults({
            portals: {
              interface: {
                id: 'interface',
                portalRef: interfaceRef,
                view: null
              },
              controller: {
                id: 'controller',
                portalRef: controllerRef,
                view: null
              }
            }
          });
        });
      }
    },
    [stage, pending]
  );

  useEffect(
    () => {
      if (stageName === stage && complete && ! pending) {
        applyChange( () => {
          updatePortals({...defaults.portals});
        });
      }
    },
    [complete, pending]
  );

  /**
   * When defaults are changed, make sure we have the latest defined portals.
   */
  const renderPortals = useCallback(
    () => {
      if (stageName === stage && complete && portals && ! pending) {
        return(
          Object.values(portals).map(
            (portal) => {
              return(
                <Portal
                  id={`${portal.id}-portal`}
                  key={`${portal.id}-portal`}
                  type={portal.id}
                  view={portal.view}
                  ref={portal.portalRef}
                />
              );
            }
          )
        );
      }
    },
    [portals, pending, complete]
  );

  return (
    <React.Fragment>
      {renderPortals()}
      <PortalContext.Provider value={portals}>
        {props.children}
      </PortalContext.Provider>
    </React.Fragment>
  );
}
Portals.propTypes = {
  children: PropTypes.node
};
export default Portals;
