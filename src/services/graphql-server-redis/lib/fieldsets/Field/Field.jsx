import React, { useState, useMemo, useLayoutEffect, useEffect, useTransition, useCallback } from 'react';
import PropTypes from 'prop-types';
import FieldView from './FieldView';
import { updateField } from 'lib/fieldsets/utils';
import { useLazyQuery } from '@apollo/react-hooks';
import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import {
  fetchFields
} from 'lib/fieldsets/graphql/queries';
import { useFunctions } from 'lib/fieldsets/Hooks';

/**
 * A field is a single data value in a set.
 */
const Field = ({ id, view = null, data, children }) => {
  const [loaded, updateLoaded] = useState(false);
  const [functions] = useFunctions();
  const [applyChange] = useTransition({timeoutMs: 5000});

  // Get our dependencies for the corresponding field.
  const [fetchDependencies, dependencies] = useLazyQuery(fetchFields, {
    displayName: `fetchFieldDependencies ${id}`,
    client: getDataCacheService(),
    variables: {data: {fields: data.children}},
    onCompleted: (result) => {
      if (!loaded && result.fetchFields && result.fetchFields.length > 0) {
        applyChange(() => {
          updateLoaded(true);
        });
      }
    }
  });


  // Data will initially come in with defaults, so this implies that this field will always need to be handled in the same manner, so it can be memoized.
  const hasDependencies = useMemo( () => { return ( data.children && data.children.length > 0 ) }, [data.children] );

  /**
   * Execute our lazyQuery before rendering.
   */
  useLayoutEffect(
    () => {
      if (hasDependencies && !dependencies.loaded && !dependencies.called && !dependencies.loading) {
        fetchDependencies();
      }
    },
    [hasDependencies,loaded,dependencies, fetchDependencies]
  );

  /**
   * Check all field values and dependencies and return final primitive result.
   */
  const calculateValue = useCallback(
    () => {
      let value = data.value;
      const deps = [...dependencies.data.fetchFields];
      // Callback correspond to keys in our functions hook
      if (data.callback && functions.hasOwnProperty(data.callback)) {
        const callback = functions[data.callback];
        value = callback(deps);
        value = Number.isNaN(value) ? 0 : value;
      };

      return value;
    },
    [data, dependencies, functions]
  );

  /**
   * Recalculate our value when dependencie data changes.
   */
   useEffect(
     () => {
       if (hasDependencies && dependencies.data && dependencies.data.fetchFields) {
         const value = calculateValue();
         const updatedField = {...data, value: value};
         updateField(id, {...updatedField});
       }
     },
     [dependencies.data, calculateValue, data, hasDependencies, id, applyChange, updateField]
   );

  const updateCache = (newvalue, event) => {
    const updatedField = {...data, value: newvalue};
    applyChange(() => {
      updateField(id, updatedField);
    });
    return updatedField;
  };


  /**
   * We don't want input field clicks to shift focus, so we stop propagation.
   */
  const handleClick = (event) => {
    const element = event.target;
    if (element && /INPUT|TEXTAREA/i.test(element.tagName)) {
      if ('selectionStart' in element) {
        element.selectionEnd = element.selectionStart;
      }
      element.blur();
    }
    //event.stopPropagation();
    return;
  }

  /**
   * We don't want input field clicks to shift focus, so we stop propagation.
   */
  const handleDoubleClick = (event) => {
    const element = event.target;
    if (/INPUT|TEXTAREA/i.test(element.tagName)) {
     element.focus();
      if (element.setSelectionRange) {
        element.setSelectionRange(0, element.value.length);
      } else {
        element.select();
      }
    }
    event.stopPropagation();
    return;
  }

  // Visually render our field
  return (
    <FieldView
      id={id}
      key={id}
      view={(view) ? view : data.type}
      field={data}
      onChange={updateCache}
      onClick={handleClick}
      onDoubleClick={handleDoubleClick}
      hasDependencies={hasDependencies}
    >
      {children}
    </FieldView>
  );
}

Field.propTypes = {
  id: PropTypes.string.isRequired,
  view: PropTypes.string,
  data: PropTypes.object.isRequired,
  children: PropTypes.node
};

export default Field;
