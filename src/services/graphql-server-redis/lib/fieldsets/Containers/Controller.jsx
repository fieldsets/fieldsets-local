import React, { createContext, useEffect, useLayoutEffect, useReducer, useCallback, useMemo, useState, useTransition } from 'react';
import PropTypes from 'prop-types';
import { Fetch, Initialize, Write } from 'lib/fieldsets/DataCache/calls';
import {useFocus, useStatus, useViewerDimensions, useDefaults, usePortals} from 'lib/fieldsets/Hooks';
import localForage from 'localforage';
import { isPrimitive } from 'lib/fieldsets/utils';

// Our contexts.
export const ControllerContext = createContext([]);

/**
 * This is container controller which handles data priming for container types as well as switching between container views.
 * This component initializes the data cache with data.
 */
const Controller = ({children}) => {
  const propTypes = {
    children: PropTypes.node
  };

  const stageName = 'controller';
  // The lifecycle stages that must be complete before rendering.
  const stageDeps = ['defaults','datacache'];
  const [current, updateStatus, lifecycle] = useStatus();
  const [{stage, status, message, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});

  const [loaded, updateLoaded] = useState(false);
  const [initialized, updateInitialized] = useState(false);

  // 'true' If data is primed for the first time, or 'false' if loaded from persistant local cache.
  const [primed, updatePrimed] = useState(true);

  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  const [focus, updateFocus] = useFocus();
  const { height, width } = useViewerDimensions();
  const [defaults, updateDefaults] = useDefaults();
  let [containers, updateContainers] = useState({});
  let [fieldsets, updateFieldSets] = useState({});

  const portals = usePortals();

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
   * We use a separate status for container priming. Containers call the controller for status management.
   * The controller can then set global state for rendering the viewer while allowing hidden containers to fetch their initial load state.
   */
  const controller = useMemo(
    () => {
      return({
        addContainer: (id, view, type, visible) => {
          if ( ! containers.hasOwnProperty(id) ) {
            containers = {
              ...containers,
              [id]: {
                id: id,
                view: view,
                type: type,
                status: 'default',
                message: '',
                visible: visible
              }
            };
            applyChange( () => {
              updateContainers({...containers});
            });
          }
        },
        updateContainerStatus: (id, status, message = '') => {
          containers[id] = {
            ...containers[id],
            status: status,
            message: message
          };
          applyChange( () => {
            updateContainers({...containers});
          });
        },
        updateContainerVisibility: (id, visible) => {
          applyChange( () => { 
              containers[id] = {
              ...containers[id],
              visible: visible
            };
          
            updateContainers({...containers});
            updateFocus({ action: 'switch', data: { id: 'current', focusID: id, focusGroup: '', expanded: false, type: containers[id].type, container: { containerID: id, type: containers[id].type }, depth: 0 }});
          });
          console.log(containers);
        },
        addFieldSet: (id, view, type, visible) => {
          if ( ! fieldsets.hasOwnProperty(id) ) {
            fieldsets = {
              ...fieldsets,
              [id]: {
                id: id,
                view: view,
                type: type,
                status: 'default',
                message: '',
                visible: visible
              }
            };
            applyChange( () => {
              updateFieldSets({...fieldsets});
            });
          }
        },
        updateFieldSetStatus: (id, status, message = '') => {
          fieldsets[id] = {
            ...fieldsets[id],
            status: status,
            message: message
          };
          applyChange( () => {
            updateFieldSets({...fieldsets});
          });
        },
        updateFieldSetVisibility: (id, visible) => {
          fieldsets[id] = {
            ...fieldsets[id],
            visible: visible
          };
          applyChange( () => {
            updateFieldSets({...fieldsets});
          });
        },
        isPrimed: () => {
          return primed;
        }
      });
    },
    [fieldsets, containers, pending, primed]
  );

  /**
   * Initialize once dependencies are complete.
   */
  useEffect(
    () => {
      if ( isReady && ! complete ) {
        applyChange( () => {
          updateStatus('initializing', 'Initializing Controller data', stageName);
        });
      }
    },
    [isReady, complete]
  );

  /**
   * Once data is primed, controller is ready to manage containers.
   */
  useEffect(
    () => {
      if ( loaded && stageName === stage && ! complete ) {
        applyChange( () => {
          updateStatus('complete', 'Container controller primed and ready.', stageName);
        });
      }
    },
    [loaded, pending, complete]
  );


  /**
   * Prime data structures.
   */
  const primeData = async () => {
    if ( ! loaded & ! complete ) {
      try {
        let promise = new Promise((resolve, reject) => {
          applyChange( () => {
            resolve(Initialize({target: 'controller', defaults: defaults}));
          });
        });
        await promise.then(
          applyChange( () => {
            updateLoaded(true);
          })
        );
      } catch (error) {
        console.error( `Initial Controller Priming Error: ${error.message}` );
        return error;
      }
    }
  };

  /**
   * Check our data store for a previous persistant save.
   */
  const loadData = async () => {
    // Check localforage for a saved state and use that instead of defaults.
    // TODO: Make this generic so we can swith to Ionic potentially since it does both web and mobile local storage.
    // TODO: Fetch data from remote source and populate locally.
    await localForage.getItem('fieldsets-datacache-persist',
      async (err, value) => {
        if (value && value.length) {
          const store = JSON.parse(value);
          Object.keys(store).forEach( key => {
            const fragment = { ...store[key] };
            if (fragment.id) {
              Object.keys(fragment).forEach( prop => {
                if ( ! isPrimitive( fragment[prop] )) {
                  const fragmentData = {...fragment[prop]};
                  if (fragmentData.type) {
                    switch (fragmentData.type) {
                      case 'json':
                        if ( fragmentData.json && Array.isArray(fragmentData.json)) {
                          fragment[prop] = [...fragmentData.json];
                        } else {
                          fragment[prop] = {...fragmentData.json}
                        }
                        break;
                      case 'id':
                      default:
                        if ( fragmentData.id && store[fragmentData.id] && store[fragmentData.id].__typename && fragmentData.typename && fragmentData.typename === store[fragmentData.id].__typename ) {
                          const storefragment = {...store[fragmentData.id]};
                          // Handle meta data
                          if (storefragment.data && storefragment.data.json && 'json' === storefragment.data.type) {
                            fragment[prop] = { ...storefragment, data: { ...storefragment.data.json } };
                          } else {
                            fragment[prop] = { ...storefragment };
                          }
                        }
                        break;
                    }
                  }
                }
              });
              const target = fragment.__typename.toLowerCase();
              Write({id: fragment.id, target: target}, {...fragment} );
            }
          });
          // Tell other initiized containers, we have loaded from local store.
          updatePrimed(false);
          // Set state that data has been loaded.
          updateLoaded(true);
        } else {
          // Prime with deferred data.
          primeData();
          // TODO: Check server and async grab last save and ovewrite cached values.
        }
      }
    )
  };

  /**
   * Once the controller is ready, prime the container data.
   */
  if ( ! initialized && isReady ) {
    applyChange( () => {
      updateInitialized(true);
      loadData();
    });
  }

  return (
    <ControllerContext.Provider value={[{containers, fieldsets}, controller]}>
      {children}
    </ControllerContext.Provider>
  );
}

export default Controller;
