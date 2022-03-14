import { Fetch, Write } from 'lib/fieldsets/DataCache/calls';

/**
 * Back fill data with defaults and a shallow merge with the spread operator.
 * Instantiate the fragment in the local cache.
 */
export const Defaults = ( call, data ) => {
  if ( data ) {
    const defaults = {...call.defaults};
    const id = call.id;
    const key = (call.key) ? call.key : call.id;
    const type = (data.type && 'field' !== call.target) ? data.type : call.target;

    // Key is set to id if not specified.
    let fragment = null;

    if (key && type) {
      const metatype = ( 'meta' === type ) ? call.parent : type;
      let metadata = { ...defaults.fragments.meta[metatype] };
      const metafields = { ...defaults.fragments.meta[metatype] };

      for (let metafield in metafields) {
        let newMeta = {};
        // Allow meta data to be passed with or  without nesting the data property.
        if ( 'meta' === call.target ) {
          if ( data.data && data.data[metafield] ) {
            newMeta = data.data[metafield];
          } else if ( data[metafield] ){
            newMeta = data[metafield];
          }
        } else if ( data.meta ) {
          if ( data.meta.data && data.meta.data[metafield] ) {
            newMeta = data.meta.data[metafield];
          } else if ( data.meta[metafield] ) {
            newMeta = data.meta[metafield];
          }
        }

        if ( newMeta.constructor === Object ) {
          if ( Object.keys(newMeta).length > 0 ) {
            metadata[metafield] = { ...metadata[metafield], ...newMeta , __typename: 'JSONObject' };
          }
        } else if ( newMeta.constructor !== Object ) {
          metadata[metafield] = newMeta;
        }
      }

      let previous = Fetch({id: id, target: call.target});
      previous = (previous) ? { ...previous } : { ...defaults.fragments[type] };

      if ( 'meta' === call.target ) {
        fragment = {
          ...previous,
          ...data,
          id: key,
          type: type,
          data: {
            ...previous.data,
            ...metadata,
            __typename: 'JSONObject'
          },
          __typename: 'Meta'
        };
      } else {
        fragment = {
          ...previous,
          ...data,
          id: key,
          meta: {
            id: key,
            type: type,
            data: {
              ...metadata,
              __typename: 'JSONObject'
            },
            __typename: 'Meta'
          }
        };
      }
      return Write({id: key, target: call.target}, {...fragment});
    }
  }
  return;
}
