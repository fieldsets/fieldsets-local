import { GraphQLJSON, GraphQLJSONObject } from 'graphql-type-json';
import { fetchFocus, fetchField, fetchFieldSet, fetchContainer } from './queries';

export const resolvers = (defaults = {}) => {
  return ({
    JSON: GraphQLJSON,
    JSONObject: GraphQLJSONObject,
    Mutation: {
      updateFocus: ( object, { data }, { client } ) => {
        let containerID = data.container.containerID;
        if (!containerID) {
          containerID = client.readQuery({query: fetchContainer});
        }
        const newfocus = {
          ...defaults.rootQuery.focus,
          ...data,
          container: {
            ...defaults.rootQuery.focus.container,
            ...data.container,
            containerID
          },
          center: {
            ...defaults.rootQuery.focus.center,
            ...data.center
          },
          zoom: {
            ...defaults.rootQuery.focus.zoom,
            ...data.zoom
          }
        };
        client.writeQuery({query: fetchFocus, data: {focus: newfocus}});
        return newfocus;
      },
      updateContainer: ( object, { data }, { client } ) => {
        // Don't use defaults for updates.
        const containerID = data.containerID;
        const cacheKey = client.cache.config.dataIdFromObject({ __typename: 'FieldSet', id: containerID });
        const container = client.readFragment({
          id: cacheKey,
          fragment: fetchFieldSet,
          fragmentName: 'fieldset'
        });
        client.writeQuery({query: fetchContainer, data: {container: container}});
        const refetch = client.readQuery({query: fetchContainer});
        return refetch.container;
      }
    },
    Query: {
      fetchContainerData: ( object, data, { client } ) => {
        const container = client.readQuery({query: fetchContainer});
        let fieldsets = [];
        container.container.children.map(
          (fieldsetID) => {
            const cacheKey = client.cache.config.dataIdFromObject({ __typename: 'FieldSet', id: fieldsetID });
            const fieldset = client.readFragment({
              id: cacheKey,
              fragment: fetchFieldSet,
              fragmentName: 'fieldset'
            });
            fieldsets.push(fieldset);
          }
        );
        return fieldsets;
      },
      fetchFields: ( object, { data }, { client } ) => {
        let fields = [];
        data.fields.map(
          (fieldID) => {
            const cacheKey = client.cache.config.dataIdFromObject({ __typename: 'Field', id: fieldID });
            const field = client.readFragment({
              id: cacheKey,
              fragment: fetchField,
              fragmentName: 'field'
            });
            fields.push(field);
          }
        );

        // We allow for specific filters here.
        let filtered = [];
        let isFiltered = false;

        if ( data ) {
          if (data.hasOwnProperty('parent')) {
            isFiltered = true;
            const parents = fields.filter( ( field ) => {
              return field.parent === data.parent;
            });
            filtered = [...filtered, ...parents];
          }
          if (data.hasOwnProperty('alwaysDisplay')) {
            isFiltered = true;
            const alwaysvisible = fields.filter( ( field ) => {
              return field.meta.alwaysDisplay === data.alwaysDisplay;
            });
            filtered = [...filtered, ...alwaysvisible];
          }
        }

        if ( isFiltered ) {
          return filtered;
        }
        return fields;
      }
    },
    Set: {
      __resolveType(obj, context, info) {
        switch( obj.type) {
          case 'account':
            return 'Account';
          case 'member':
            return 'Member'
          case 'role':
            return 'Role'
          case 'set':
            return 'Set'
          case 'field':
            return 'Field'
          default:
            return 'FieldSet'
        }
      }
    },
    Coordinate: {
      __resolveType(obj, context, info) {
        if (obj.scale) {
          return 'Zoom'
        }
        return 'Center';
      }
    },
  }
)}
