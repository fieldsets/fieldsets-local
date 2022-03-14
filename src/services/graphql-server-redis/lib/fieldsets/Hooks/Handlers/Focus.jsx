/**
 * Focus is a react context that allows components to know what the current user focus is and wheter or not the should be visible..
 */
import React, {createContext, useReducer, useEffect, useLayoutEffect} from 'react';
import { useLazyQuery, useMutation } from '@apollo/react-hooks';
import {useDefaults} from 'lib/fieldsets/Hooks';
import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import {
  fetchFocus,
  fetchContainer,
  updateFocus,
  updateContainer
} from 'lib/fieldsets/graphql/queries';
import {useStatus} from 'lib/fieldsets/Hooks';

// Our focus context.
export const FocusContext = createContext({});

/**
 * Our focus is a local cache fragement. It uses the id of 'current' for it along with the it's corresponding container.
 */
export const Focus = ( {children} ) => {
  const client = getDataCacheService();

  const [{status}, updateStatus] = useStatus();
  const [defaults] = useDefaults();

  /**
   * Read the current active focus from the data store
   */
  const [fetchFocusData, focus] = useLazyQuery(fetchFocus, {
    client: client
  });

  /**
   * Read the current active focused container from the data store
   */
  const [fetchFocusedContainer, container] = useLazyQuery(fetchContainer, {
    client: client
  });

  /**
   * Update the current active focus in the data store
   */
  const [updateFocusData] = useMutation(updateFocus, {
    client: client,
    refetchQueries: [{query:fetchFocus}],
    awaitRefetchQueries: true
  });

  /**
   * Re-prime the cache data when switching container focus.
   */
  const [updateContainerData] = useMutation(updateContainer, {
    client: client,
    refetchQueries: [{query:fetchContainer}],
    awaitRefetchQueries: true
  });

  const setContainer = ( newContainer = false ) => {
    if (! newContainer ) {
      newContainer = {...focus.data.focus.container};
    }

    if ( 'default' !== newContainer.containerID ) {
      updateContainerData({ variables: { data: newContainer } });
      //fetchFocusedContainer();
    }

    return newContainer;
  };

  const getFocus = () => {
    updateStatus('focusing', 'Fetching current focus.');
    return fetchFocusData();
  }

  // Our reducer to set the focus.
  const setFocus = (current, call = {}) => {
    // Get the latest focus.
    if (call.action) {
      const focusdata = call.data;
      switch (call.action) {
        // change entire container focus
        case 'switch':
          current = mergeFocus(focusdata);
          current.container = (focusdata.container) ? {...focusdata.container} : {...focus.data.focus.container};
          current.container.__typename = 'JSONObject';
          setContainer(current.container);
          break;

        // Change focus withing container.
        case 'focus':
          // Fetch our metadata about our new focus.
          current = mergeFocus(focusdata);
          updateStatus('focused', 'Change focus fieldset.');
          break;

        // Get more information on current focus.
        case 'expand':
          // Fetch our metadata about our new focus.
          current = mergeFocus(focusdata);
          updateStatus('expanded', 'Expanded focused fieldset.');
          break;
        default:
          break;
      }
      updateFocusData( { variables: { data: current } } );
    }
    return current;
  }

  const mergeFocus = (data) => {
    let newfocus = (focus.data) ? {...focus.data.focus} : {...defaults.rootQuery.focus};
    const currentContainer = (container.data) ? { ...container.data.container } :  { ...defaults.rootQuery.focus.container };

    /**
     * Handle how we set values that aren't specified in the data set when we merge.
     */
    newfocus.focusID = (data.focusID) ? data.focusID : newfocus.focusID;
    newfocus.focusGroup = (typeof data.focusGroup !== 'undefined') ? data.focusGroup : newfocus.focusGroup;
    newfocus.type = (data.type) ? data.type : newfocus.type;
    newfocus.expanded = (data.expanded) ? data.expanded : newfocus.expanded;
    newfocus.container = (data.container) ? {...data.container} : { containerID: currentContainer.id, type: currentContainer.type, __typename: 'JSONObject' };
    newfocus.center = (data.center) ? {...data.center} : {...newfocus.center};
    newfocus.center.__typename = 'JSONObject';
    newfocus.zoom = (data.zoom) ? {...data.zoom} : {...newfocus.zoom};
    newfocus.zoom.__typename = 'JSONObject';
    newfocus.depth = (data.depth) ? data.depth : newfocus.depth;
    newfocus.__typename = 'Focus';

    return newfocus;
  }

  /**
   * If we change containers, we need to fetch the fieldsets asscociated with the current focus.
   */
  useEffect(
    () => {
      if ( focus && ! focus.loading ) {
        switch (status) {
          case 'primed':
          case 'switched':
            if ( ! ( focus.called && focus.data ) ) {
              getFocus();
            }
            break;
          default:
            break;
        }
      }
    },
    [status]
  );

  /**
   * If we change containers, we need to fetch the fieldsets asscociated with the current focus.
   */
  useLayoutEffect(
    () => {
      if (focus.called && !(focus.loading) && focus.data.focus.container) {
        setContainer(focus.data.focus.container);
      }
    },
    [focus]
  );


  return (
    <FocusContext.Provider value={useReducer( setFocus, defaults.rootQuery.focus )}>
      {children}
    </FocusContext.Provider>
  );
}
