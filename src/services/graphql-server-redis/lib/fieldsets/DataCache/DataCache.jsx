import React, { useState, useEffect, useLayoutEffect, useMemo, useTransition } from 'react';
import { ApolloProvider } from 'react-apollo';
import { getDataCacheService } from './DataCacheService';
import { useStatus, useDefaults } from 'lib/fieldsets/Hooks';
import { resolvers, typeDefs } from 'lib/fieldsets/graphql';

/**
 * Our Data cache wrapper around apollo/graphql, indexDB and PostgreSQL.
 * The data cache is a react component that contains all of our fieldsets, subsets and metasets and is used to performantly load large lists of data.
 */
const DataCache = ({children}) => {
  const stageName = 'datacache';
  // The lifecycle stages that must be complete before rendering.
  const stageDeps = ['defaults'];
  const [current, updateStatus, lifecycle] = useStatus();
  const [{stage, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});

  const [connected, updateConnected] = useState(false);
  const [initialized, updateInitialized] = useState(false);

  const [defaults] = useDefaults();
  const [applyChange] = useTransition({timeoutMs: 5000});

  // Allow us to use our defaults Hook and have an globally scoped datacacheservice as well.
  const config = useMemo(
    () => {
      return({resolvers: resolvers(defaults), typeDefs: typeDefs, defaults: defaults})
    },
    [defaults]
  );

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
    [lifecycle, complete, stageDeps]
  );

  const initCache = async () => {
    // await before instantiating ApolloClient, else queries might run before the cache is persisted
    if ( ! connected ) {
      try {
        await getDataCacheService(config);
        applyChange( () => {
          updateConnected(true);
        });
      } catch (error) {
        console.error( `Data Cache Load Error: ${error.message}` );
        return error;
      }
    }
    return getDataCacheService(config);
  }

  // Initialize cache and wait for it to finish.
  useEffect(
    () => {
      if ( isReady ) {
        applyChange( () => {
          // Take handoff from default initialization.
          // Our defaults stage is complete so lets trigger that here.
          updateStatus('initializing', 'Initializing data cache...', stageName);
        });
      }
    },
    [isReady]
  );

  // Initialize cache and wait for it to finish.
  useEffect(
    () => {
      if ( stageName === stage && connected ) {
        applyChange( () => {
          // Take handoff from default initialization.
          // Our defaults stage is complete so lets trigger that here.
          updateStatus('complete', 'Datacache connection established...', stageName);
        });
      }
    },
    [stage, connected]
  );

  if ( ! initialized ) {
    applyChange( () => {
      updateInitialized(true);
      initCache();
    });
  }

  return (
    <ApolloProvider client={getDataCacheService(config)}>
      {children}
    </ApolloProvider>
  );
};

export default DataCache;
