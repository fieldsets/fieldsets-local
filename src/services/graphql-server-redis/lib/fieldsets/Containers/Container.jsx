import React, { createContext, useEffect, useLayoutEffect, useReducer, useCallback, useMemo, useState, useTransition } from 'react';
import { useLazyQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import { Fetch, Initialize, Write } from 'lib/fieldsets/DataCache/calls';
import {
  fetchContainerData
} from 'lib/fieldsets/graphql/queries';
import {useFocus, useStatus, useViewerDimensions, useDefaults, useController} from 'lib/fieldsets/Hooks';

// Our contexts.
export const ContainerContext = createContext([
  {
    fieldsets: [],
    meta: {},
    loaded: false
  },
  () => {}
]);

/**
 * This is the generic Fieldset Container which Handles data priming for container types.
 * This component initializes the data cache with data, as well as setting up the underlying coordinate system for tracking interactions.
 */
const Container = ({id, name, type = 'container', view, meta: metadata, visible: isVisible = false, children}) => {
  const [{containers}, controller] = useController();

  const stageName = 'container';
  // The lifecycle stages that must be complete before rendering.
  const stageDeps = ['defaults', 'datacache', 'controller'];
  const [current, updateStatus, lifecycle] = useStatus();
  const [{stage, status, message, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});

  const [loaded, updateLoaded] = useState(false);
  const [initialized, updateInitialized] = useState(false);

  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  const [focus, updateFocus] = useFocus();
  const [fieldsets, updateFieldSets] = useState([]);
  const [meta, updateMeta] = useState(metadata);
  const { height, width } = useViewerDimensions();
  const [defaults, updateDefaults] = useDefaults();
  const [visible, updateVisibility] = useState(isVisible);

  const [containerData, updateContainerData] = useState({id, fieldsets, meta, complete, visible});

  /**
   * Our lazyloaded query. Will read the root query container children and set the container data accordingly.
   */
  const [fetchContainerFieldSets, { loading, called, data, refetch }] = useLazyQuery(fetchContainerData, {
    displayName: `fetchContainerFieldSets ${id}`,
    client: getDataCacheService(),
    onCompleted: (result) => {
      if (result && result.fetchContainerData && result.fetchContainerData.length > 0) {
        applyChange( () => {
          updateFieldSets(result.fetchContainerData);
          updateLoaded(true);
        });
      }
    }
  });

  /**
   * If the global stage is a container, we then pass off status management to the individual container and the controller.
   */
  useLayoutEffect(
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
   * Make the controller aware of this container.
   */
  useLayoutEffect(
    () => {
      if ( ! containers.hasOwnProperty(id) ) {
        applyChange( () => {
          controller.addContainer(id, view, type, visible);
        });
      }
    },
    [isReady]
  );

  /**
   * Set container local status off of controller status.
   */
  useLayoutEffect(
    () => {
      if (stageName === current.stage && containers && containers[id] && ! containers[id].complete) {
        applyChange( () => {
          setStatus({stage: stageName, status: containers[id].status, message: containers[id].message, complete: false});
        });
      }
    },
    [containers]
  );

  /**
   * Sync controller visibility with current visibility.
   */
  useLayoutEffect(
    () => {
      if (isReady && loaded) {
        applyChange( () => {
          updateVisibility(containers[id].visible);
        });
      }
    },
    [containers[id]]
  );

  /**
   * Tells us if the controller loaded all of this container's dependencies.
   */
  const isReady = useMemo(
    () => {
      if (complete) {
        return true;
      }
      let depsMet = true;
      for (const dep of stageDeps) {
        if ( lifecycle[dep] ) {
          depsMet = lifecycle[dep].complete;
        } else {
          depsMet = false;
        }
        if (!depsMet) {
          break;
        }
      }
      return depsMet;
    },
    [lifecycle]
  );

  /**
   * Initialize once dependencies are complete.
   */
  useEffect(
    () => {
      if ( isReady && ! complete && ! loaded && ! initialized) {
        applyChange( () => {
          updateStatus('initializing', 'Initializing containers', stageName);
          controller.updateContainerStatus(id, 'priming', `Priming ${name} data`);
        });
      }
    },
    [isReady, complete]
  );

  /**
   * Once loaded Watch for container changes.
   */
  useEffect(
    () => {
      if ( focus.container.containerID === id && 'interface' !== type.toLowerCase() ) {
        console.log({loaded, focus, called, loading, visible: containers[id].visible, id, container: focus.container});

        if ( containers[id].visible ) {
          updateVisibility(containers[id].visible);
          // loaded initially, then refetch
          if ( ! called && ! loading ) {
            applyChange( () => {
              
              if ( loaded ) {
                refetch();
              } else {
                fetchContainerFieldSets();
              }
            });
            controller.updateContainerStatus(id, 'ready', `Container ready`);
          }
        }
      }
    },
    [focus.container.containerID]
  );


  /**
   * Once the container is ready, set it's visibility accordinging and set complete to 'true'
   */
  useEffect(
    () => {
      if ( stageName === current.stage && containers && containers[id] && ! containers[id].complete && 'ready' === containers[id].status && loaded && ! pending ) {
        applyChange( () => {
          setStatus({stage, status, message, complete: true});
          updateVisibility(containers[id].visible);
        });
      }
    },
    [containers, loaded, pending]
  );

  /**
   * Once complete wait for all other containers to complete before changing status.
   */
  useEffect(
    () => {
      if (complete && stageName === current.stage) {
        applyChange( () => {
          if( Object.values(containers).filter((container) => 'ready' !== container.status).length === 0 ) {
            updateStatus('complete', 'All containers ready for rendering', stageName);
          }
        });
      }
    },
    [containers, complete]
  );


  /**
   * Set our container data and pass it on for rendering.
   */
   useLayoutEffect(
    () => {
      if (loaded && complete) {
        applyChange( () => {
          updateContainerData({id,fieldsets, meta, complete, visible})
        });
      }
    },
    [fieldsets, meta, loaded, complete]
  );

  /**
   * Active means that the container is visible to the user.
   */
  const isActive = useMemo(
    () => {
      if (containers && containers[id]) {
        return containers[id].visible;
      }
      return false;
    },
    [containers]
  );

  /**
   * Query the last save of the current container and use it to initialize. Otherwise fallback on defaults defined in 'data/defaults'
   */
  const initContainer = async () => {
    // await before instantiating ApolloClient, else queries might run before the cache is persisted
    try {
      let promise = new Promise((resolve, reject) => {
        resolve( Initialize({key: id, id: view, name: name, meta: meta, target: type, defaults: defaults}));
      });
      await promise.then(
        ()=> {
          applyChange( () => {
            controller.updateContainerStatus(id, 'initialized', `${name} initialized`);
          });
        }
      );
    } catch (error) {
      console.error( `Container Initilization Error: ${error.message}` );
      return error;
    }
  };

  /**
   * Initialize cache if no local data exists.
   */
  useEffect(
    () => {
      if (stageName === stage && 'initializing' === status && ! initialized) {
        applyChange( () => {
          updateInitialized(true);
          if ( controller.isPrimed() ) {
            initContainer();
          } else {
            controller.updateContainerStatus(id, 'initialized', `${name} initialized`);
          }
        });
      }
    },
    [stage, status]
  );


  // Wait For cache connection, and then for controller to prime data to fetch results.
  useEffect(
    () => {
      if ( stageName === stage && 'initialized' === status ) {
        applyChange(
          () => {
            const containerMeta = Fetch({id: id, target: 'meta'});
            // Make sure our current meta has all the defaults backfilled.
            if (containerMeta) {
              updateMeta({...containerMeta});
            }

            // If this container is flagged as load as default focus, add it to the root query and allow our view render to occur.
            if (visible) {
              if ('interface' !== type.toLowerCase()) {
                const container = { containerID: id, type: containerMeta.type };

                updateFocus({ action: 'switch', data: { id: 'current', focusID: id, focusGroup: '', expanded: false, type: containerMeta.type, container: {...container}, depth: 0 }});
              }
            }
            controller.updateContainerStatus(id, 'ready', `Container ready`);
          }
        );
      }
    },
    [status]
  );

  return (
    <ContainerContext.Provider value={containerData}>
      {children}
    </ContainerContext.Provider>
  );

}
Container.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  type: PropTypes.string.isRequired,
  view: PropTypes.string,
  meta: PropTypes.object,
  visible: PropTypes.bool,
  children: PropTypes.object
};

export default Container;
