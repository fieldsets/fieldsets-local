import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache, IntrospectionFragmentMatcher } from 'apollo-cache-inmemory';
import { CachePersistor } from 'apollo-cache-persist';
import introspectionQueryResultData from 'fragmentTypes.json';
import localForage from 'localforage';

const config = require('config.json');
const GRAPHQL_SERVER = config.servers.graphql;

const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData
});

const cache = new InMemoryCache({ fragmentMatcher });
let DataCacheService;
let DataCacheStore;

/**
 * The Cache Persistore provides the following Methods:
 * DataCacheStore.restore();   // Immediately restore the cache. Returns a Promise.
 * DataCacheStore.persist();   // Immediately persist the cache. Returns a Promise.
 * DataCacheStore.purge();     // Immediately purge the stored cache. Returns a Promise.
 *
 * DataCacheStore.pause();     // Pause persistence. Triggers are ignored while paused.
 * DataCacheStore.resume();    // Resume persistence.
 * DataCacheStore.remove();    // Remove the persistence trigger. Manual persistence required after calling this.
 *
 * // Obtain the most recent 30 persistor loglines.
 * // `print: true` will print them to the console; `false` will return an array.
 * DataCacheStore.getLogs(print);

 * // Obtain the current persisted cache size in bytes. Returns a Promise.
 * // Resolves to 0 for empty and `null` when `serialize: true` is in use.
 * DataCacheStore.getSize();
 */
export const getDataCacheStore = async () => {
  if (! DataCacheStore) {
    // await before instantiating ApolloClient, else queries might run before the cache is persisted
    try {
      DataCacheStore = await new CachePersistor({
        cache,
        storage: localForage,
        key: 'fieldsets-datacache-persist',
        maxSize: 10485760, // 10MB maxSize. This was arbitrarily set. If problems arise, change as needed.
        debug: true
      });
    } catch (error) {
      console.error('Persistent Data Store Load Error:', error);
    }
  }
  return DataCacheStore;
}

/**
 * Instantiate our datacache service so we can access it outside of a component if needed.
 */
export const getDataCacheService = (variables = false) => {
  if (! DataCacheService && variables) {
    getDataCacheStore();
    DataCacheService = new ApolloClient({
      name: 'fieldsets-datacache',
      link: new HttpLink({
        uri: `${GRAPHQL_SERVER}/graphql`
      }),
      connectToDevTools: true,
      cache,
      resolvers: {...variables.resolvers},
      typeDefs: variables.typeDefs,
    });
    cache.writeData({
      data: variables.defaults.rootQuery
    });
  }
  return DataCacheService;
}
