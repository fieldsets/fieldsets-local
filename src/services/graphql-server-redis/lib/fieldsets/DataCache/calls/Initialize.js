import { Fetch, Update, Defaults } from 'lib/fieldsets/DataCache/calls';
import {FieldData, SetData, MetaData} from 'data';

/**
 * Our Set Utility function
 */
export const Initialize = ( call ) => {
  const id = call.id;
  const key = call.key;
  const defaults = (call.defaults) ? {...call.defaults} : {};
  let meta = {};
  let name = '';

  switch (call.target) {
    // Load all fields when we load the controller.
    case 'Controller':
    case 'controller':
      initializeSetData( { data: SetData, defaults: {...defaults} } );
      initializeFieldData( { data: FieldData, defaults: {...defaults} } );
      initializeMetaData( { data: MetaData, defaults: {...defaults} } );
      return;
    // Initialize using the call id
    case 'Diagram':
    case 'diagram':
      meta = { ...call.meta, view: id, __typename: 'Meta' };
      name = call.name;

      // Write our diagram fieldset as a special type.
      // Write our container fieldset that called this init
      Defaults(
        {id: key, target: 'diagram', defaults: {...defaults}},
        {id: key, name: name, type: 'diagram', parent: 'container', meta: {...meta} }
      );

      // Our fragments have all been written. Refetch fragment to return as a result.
      return Fetch({id: key, target: 'diagram'});
    case 'Interface':
    case 'interface':
      return;
    case 'Sheet':
    case 'sheet':
      meta = { ...call.meta, view: id, __typename: 'Meta' };
      name = call.name;

      // Write our diagram fieldset as a special type.
      // Write our container fieldset that called this init
      Defaults(
        {id: key, target: 'sheet', defaults: {...defaults}},
        {id: key, name: name, type: 'sheet', parent: 'container', meta: {...meta} }
      );

      // Our fragments have all been written. Refetch fragment to return as a result.
      const sheet = Fetch({id: key, target: 'sheet'});
      return sheet;
    default:
      return;
  }
}

const initializeSetData = ({ data = [], defaults = {} }) => {
  return data.map((set) => {
    if ( set.id ) {
      // Check if the fragment exists already
      const setID = set.id;

      // Write the defaults
      set.fields = (set.fields && set.fields.length) ? set.fields : [];
      let setFragment = Defaults({id: setID, target: 'fieldset', defaults: {...defaults}}, {...set});

      // Iterating over children appends the id to our array, so we can set our array to empty.
      setFragment.children = [];
      // Write the fragment
      Update({id: setID, target: 'fieldset'}, {...setFragment});

      // Now append this set to the parent fieldset list
      // Write our fieldset & set relationships
      if (set.parent && set.parent.length > 0) {
        // Make sure parent set exists in cache.
        let parent = Fetch({id: set.parent, target: 'fieldset'});
        if ( ! parent ) {
          parent = Defaults({id: set.parent, target: 'fieldset', defaults: {...defaults}}, {id: set.parent, children: [], fields: []});
        }
        if ( ! parent.children.includes(setID) ) {
          Update({id: set.parent, target: 'fieldset', filter: 'children'}, setID);
        }
      }

      // Write our child fragments.
      if (set.children && set.children.length > 0) {
        initializeSetData({ data: [...set.children], defaults: {...defaults} });
      }
      return true;
    }
    return false;
  });
};

const initializeFieldData = ({ data = [], defaults = {} }) => {
  if (!data.length) {
    return;
  }
  // Get your fields here. This is defined as a static json, but could be modified here to get remote field type definitions.
  return (data.map((field) => {
    if (field.id) {
      const fieldID = field.id;
      const fieldFragment = Defaults( {id: fieldID, target: 'field', defaults: {...defaults}}, {...field} );
      const fieldData = Update({id: fieldID, target: 'field'}, { ...fieldFragment });

      // Field parents are arrays as a fields can belong to multiple sets.
      // Make sure we push to the top level id that was initialized as well, but don't classify it as a parent fieldset to the field.
      field.fieldsets = (field.fieldsets) ? [...field.fieldsets] : [];
      for ( let fieldSetID of field.fieldsets ) {
        if ( fieldSetID.length > 0 ) {
          Defaults({id: fieldSetID, target: 'fieldset', defaults: {...defaults}}, {id:fieldSetID, type: 'fieldset'});
          Update({id: fieldSetID, target: 'fieldset', filter: 'fields'}, fieldID);
        }
      }
      return fieldData;
    }
    return field;
  }));
}

const initializeMetaData = ({ data = [], defaults }) => {
  return(data.map((meta) => {
    if (meta.id) {
      const metaID = meta.id;

      // We default to populating fieldsets here if it's not specified in the default data files.
      if (! meta.type) {
        meta.type = 'fieldset'
      }
      const metatype = meta.type;

      const metaFragment = Defaults( {id: metaID, target: 'meta', defaults: defaults}, {...meta} );
      const metaData = Update({id: metaID, target: 'meta', type: metatype}, {...metaFragment});
      return metaData;
    }
    return meta;
  }));
}
