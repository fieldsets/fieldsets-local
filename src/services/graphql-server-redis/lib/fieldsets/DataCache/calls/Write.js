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
 * Our Cache Write Wrapper. Overwrites key with passed full data set data. No filters allowed or meta writes allowed.
 */
export const Write = ( call, data ) => {
  if ( data ) {
    const client = getDataCacheService();
    const id = call.id;
    const key = (call.key) ? call.key : id;

    // Key is set to id if not specified.
    if (key && data) {
      let fragmentID = '';
      let fragmentQuery = '';
      let fragmentName = call.target;

      // Our fetch queries
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
          fragmentName = 'fieldset';
          break;
      }

      client.writeFragment({
        id: fragmentID,
        fragment: fragmentQuery,
        fragmentName: fragmentName,
        data: { ...data }
      });

      const result = client.readFragment({
        id: fragmentID,
        fragment: fragmentQuery,
        fragmentName: fragmentName
      });
      return result;
    } else {
      throw new Error('You must specify an id or key to write to.');
    }
  } else {
    throw new Error('Cache write called with empty data.');
  }
}
