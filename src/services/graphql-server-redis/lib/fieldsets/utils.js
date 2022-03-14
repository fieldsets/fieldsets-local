import { Fetch, Update } from 'lib/fieldsets/DataCache/calls';


/**
 * A recursive function for getting all children.
 */
export const getSubsets = (id, type = 'fieldset', subsets = []) => {
  const parent = Fetch({id: id, target: type});
  // Subsets will always be fieldsets.
  if ( 'fieldset' === type ) {
    subsets.push(id);
  }
  if (parent && parent.children && parent.children.length > 0) {
    parent.children.map(
      (setid) => {
        return getSubsets(setid, 'fieldset', subsets);
      }
    );
  }
  return subsets;
}

/**
 * Check if a field value is a primitive value.
 */
export const isPrimitive = (fieldvalue) => {
  if (typeof fieldvalue === 'string' || typeof fieldvalue === 'number' || typeof fieldvalue === 'boolean') {
    return true;
  }
  return false;
};

/**
 * Find numeric value of an input.
 * Will allow field id's and look up corresponding values
 * Will cast null values as 0.
 */
export const castNumeric = (value) => {
  let number = Number(value);
  if ( Number.isNaN(number) ) {
    // If we don't have a number, test to see if it is a cached field id
    const fieldvalue = fetchFieldValue(value);
    // Means we have a cache hit.
    if (fieldvalue !== null) {
      number = Number(fieldvalue);
      if ( Number.isNaN(number) ) {
        return Error(`Field ${value} has a value of ${fieldvalue} which cannot be cast to a number.`);
      }
    } else {
      return Error(`${value} cannot be cast to a number and is not a valid field id.`);
    }
  }
  return number;
}

/**
 * Check our type of field return corresponding numeric value.
 */
export const getNumericValue = (field, calledby = '') => {
  if (calledby.length > 0) {
    calledby = `function ${calledby}(): `;
  }
  let fieldvalue = field;
  switch ( typeof field ) {
    case 'numeric':
    case 'bigint':
    case 'string':
      try {
        fieldvalue = castNumeric(field);
      } catch (e) {
        console.error(`${calledby}Primitive value passed cannot be cast. ${e.message}`);
      }
      return fieldvalue;
    case 'function':
      fieldvalue = field();
      try {
        fieldvalue = castNumeric(fieldvalue);
      } catch (e) {
        console.error(`${calledby}Function called returns an invalid value. ${e.message}`);
      }
      return fieldvalue;
    case 'object':
      if ( 'field' === field.__typename.toLowerCase() ) {
        if (field.hasOwnProperty('value')) {
          try {
            fieldvalue = castNumeric(field.value);
          } catch (e) {
            console.error(`${calledby}Field Object passed cotains an invalid value. ${e.message}`);
          }
          return fieldvalue;
        } else {
          try {
            throw new Error(`${calledby}Field Object passed does not have the value property.`);
          } catch (e) {
            console.error( e.message );
            return;
          }
        }
      } else {
        try {
          throw new Error(`${calledby}Object passed does not have the property __typename === 'field'.`);
        } catch (e) {
          console.error( e.message );
          return;
        }
      }
    default:
      try {
        throw new Error(`${calledby}Field of ${field} is not a valid data type and returns ${typeof field}`);
      } catch (e) {
        console.error( e.message );
        return;
      }
  }
};


/**
 * DATA UTILS
 */

/**
 * Get the cached value of a field.
 */
export const fetchFieldValue = (id) => {
  return Fetch({id: id, target: 'field', filter: 'value'});
}

/**
 * Fetch a field fragment from the data cache.
 */
export const fetchField = (id) => {
  return Fetch({id: id, target: 'field'});
}

/**
 * Update a field fragment in the data cache.
 */
export const updateField = (id, data) => {
  return Update({id: id, target: 'field'}, {...data} );
}

/**
 * END DATACACHE UTILS
 */
