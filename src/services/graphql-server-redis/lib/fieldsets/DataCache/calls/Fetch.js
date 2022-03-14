import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import {
  fetchField,
  fetchFieldSet,
  fetchMeta,
  fetchAccount,
  fetchRole,
  fetchMember
} from 'lib/fieldsets/graphql/queries';

/**
 * Our Cache Fetch wrapper function. We use this to read fragments directly from the cache. Standard grapqhl queries should be handled in their corresponding resolvers.
 */
export const Fetch = ( call ) => {
  const client = getDataCacheService();
  const id = call.id;
  const key = (call.key) ? call.key : id;
  const filter = (call.filter) ? call.filter : '';

  let result = null;

  // These are our fetchAll queries
  // Key is set to id if not specified.
  if (key) {
    let fragmentID = '';
    let fragmentQuery = '';
    let fragmentName = call.target;
    // TODO: Check these types against defaults SetTypes
    if ( 'diagram' === fragmentName || 'interface' === fragmentName || 'sheet' === fragmentName || 'chart' === fragmentName || 'controller' === fragmentName) {
      fragmentName = 'fieldset';
    }
    // Our fetch single calls
    switch (call.target) {
      case 'field':
        fragmentID = `Field:${key}`;
        fragmentQuery = fetchField;
        break;
      case 'meta':
        fragmentID = `Meta:${key}`;
        fragmentQuery = fetchMeta;
        break;
      case 'account':
        fragmentID = `Account:${key}`;
        fragmentQuery = fetchAccount;
        break;
      case 'member':
        fragmentID = `Member:${key}`;
        fragmentQuery = fetchMember;
        break;
      case 'role':
        fragmentID = `Role:${key}`;
        fragmentQuery = fetchRole;
        break;
      case 'diagram':
      case 'interface':
      case 'sheet':
      case 'fieldset':
      default:
        fragmentID = `FieldSet:${key}`;
        fragmentQuery = fetchFieldSet;
        break;
    }
    // Get our Result!
    result = client.readFragment({
      id: fragmentID,
      fragment: fragmentQuery,
      fragmentName: fragmentName
    });

    if ( result ) {
      // Handle filters.
      switch( filter ) {
        case '':
        case 'all':
          break;
        case 'subsets':
        case 'children':
        case 'sets':
        case 'accounts':
        case 'subaccounts':
          result = [...result.children];
          break;
        case 'fieldsets':
          // Fields have a fieldsets list of ids. Return those fieldsets if this call targets a field instead of a set.
          // Both of these result lists are not lists of fieldsets. So we iterate through them to generate our list.
          let resultList = [];

          for ( let fieldsetID of result.fieldsets ) {
            const fieldset = client.readFragment({
              id: `FieldSet:${fieldsetID}`,
              fragment: fetchFieldSet,
              fragmentName: 'fieldset'
            });
            resultList.push(fieldset);
          }
          result = [...resultList];
          break;
        default:
          // Assume query is asking for a filter of the data json object.
          if ( 'meta' === call.target && 'data' !== filter) {
            result = (result.data[filter]) ? result.data[filter] : null;
          } else {
            // The filter should exist as a property of our result, otherwise just return the entire result as the filter may be on meta data that is not a proper JSON object.
            result = (result[filter]) ? result[filter] : null;
          }
          break;
      }
    }
  } else {
    throw new Error('You must specify an id or key to fetch.');
  }
  return result;
}
