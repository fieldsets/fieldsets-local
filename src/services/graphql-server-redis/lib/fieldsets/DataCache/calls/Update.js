import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import { Fetch } from './Fetch';
import {
  fetchField,
  fetchFieldSet,
  fetchMeta,
  fetchAccount,
  fetchRole,
  fetchMember
} from 'lib/fieldsets/graphql/queries';

/**
 * Our Cache Update Wrapper and merge with previous values.
 */
export const Update = ( call, data ) => {
  if ( data ) {
    const client = getDataCacheService();
    const id = call.id;
    const key = (call.key) ? call.key : id;
    const filter = (call.filter) ? call.filter : '';
    let type = (call.type) ? call.type : call.target;

    let noFilterCall = {...call};
    noFilterCall.filter = '';

    if ( 'meta' === call.target && 'meta' === type) {
      type = ( data.type ) ? data.type : 'fieldset';
    }

    // Key is set to id if not specified.
    if (key) {
      let fragmentID = '';
      let fragmentQuery = '';
      let fragmentName = call.target;
      let previous = {};

      // To get our previous result, remove the filter so we can apply the filter update later on the full fragment.
      if ( 'meta' === call.target ) {
        previous = Fetch({ ...noFilterCall, ...{ target: type, type: null } });
      } else {
        previous = Fetch({...noFilterCall});
      }

      if (! previous) {
        // Initializing missing ids.
        console.error(`Something is not right. A cache entry should exist for ${key}. Check the id and ensure it exists in your data structure. For now, we will set it to empty.`);
        previous = {
          fieldsets: [],
          children: [],
          meta: {
            data: {}
          }
        }
      }

      // Ensure our IDs are correct since may have grabbed defaults.
      // Ensure if we used defaults, we ov
      previous = {
        ...previous,
        id: key,
        type: type,
        meta: {
          ...previous.meta,
          id: key,
          type: type,
          __typename: 'Meta'
        }
      };


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
        case 'sheet':
        case 'interface':
        case 'fieldset':
        default:
          fragmentID = `FieldSet:${key}`;
          fragmentQuery = fetchFieldSet;
          fragmentName = 'fieldset';
          break;
      }

      // Handle filters, if we are updating a specific property of a fragment.
      switch( filter ) {
        case '':
        case 'all':
          // Merge the previous and current data set.
          // If the current data set is metadata
          if ( 'meta' === call.target) {
            const metadata = { ...previous.meta.data, ...data.data };
            previous = {
              ...previous.meta,
              ...data,
              data: {...metadata}
            };
          } else {
            const metadata = { ...previous.meta.data, ...data.meta.data };
            previous = {
              ...previous,
              ...data,
              meta: {
                ...previous.meta,
                ...data.meta,
                data: {...metadata}
              }
            };
          }
          break;
        case 'subsets':
        case 'children':
        case 'accounts':
        case 'subaccounts':
          previous.children.push(data);
          break;
        case 'fieldsets':
          // Fields have a fieldsets list of ids. Push the id accordingly.
          if ('field' === call.target) {
            previous.fieldsets.push(data);
          } else if ( 'fieldset' === call.target ) {
            // Order only matters on fieldsets that aren't containers.
            const order = (data.order) ? data.order : 0;
            if ( order > 0 && !(previous.children[order]) ) {
              previous.children[order] = data;
            } else {
              previous.children.push(data);
            }
          } else {
            previous.children.push(data);
          }
          break;
        default:
          if ( 'meta' === call.target ) {
            if ( previous.meta[filter] ) {
              if (typeof previous.meta[filter] === 'object') {
                previous.meta[filter] = { ...previous.meta[filter], ...data }
              } else {
                previous.meta[filter] = data;
              }
            } else if ( previous.meta.data[filter] ) {
              if (typeof previous.meta.data[filter] === 'object') {
                previous.meta.data[filter] = { ...previous.meta.data[filter], ...data }
              } else {
                previous.meta.data[filter] = data;
              }
            } else {
              const newdata = { [filter] : data };
              previous.meta.data = { ...previous.meta.data, ...newdata };
            }
          } else if ( previous[filter] ) {
            previous[filter] = (previous[filter]) ? previous[filter] : [];
            // The filter should exist as a property of our result, otherwise just return the entire result as the filter may be on meta data that is not a proper JSON object.
            previous[filter].push(data);
          } else {
            previous[filter] = data
          }
          break;
      }

      // We've merged our data with our previous data. Let's write!
      client.writeFragment({
        id: fragmentID,
        fragment: fragmentQuery,
        fragmentName: fragmentName,
        data: { ...previous }
      });
      return client.readFragment({
        id: fragmentID,
        fragment: fragmentQuery,
        fragmentName: fragmentName
      });

    } else {
      throw new Error('You must specify an id or key to write to.');
    }
  } else {
    throw new Error('Cache write called with empty data.');
  }
}
