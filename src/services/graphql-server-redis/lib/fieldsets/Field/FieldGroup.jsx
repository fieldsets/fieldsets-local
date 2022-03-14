import React, { useEffect, useState, useCallback } from 'react';
import { useLazyQuery } from '@apollo/react-hooks';
import { getDataCacheService } from 'lib/fieldsets/DataCache/DataCacheService';
import PropTypes from 'prop-types';
import * as FieldGroups from './Groups';
import * as CustomFieldGroups from 'components/Fields/Groups';
import {
  fetchFields
} from 'lib/fieldsets/graphql/queries';

export const FieldGroup = (props) => {
  const {id, type, active, visible, variables, children} = {...props};

  const propTypes = {
    id: PropTypes.string.isRequired,
    type: PropTypes.string,
    active: PropTypes.boolean,
    visible: PropTypes.boolean,
    variables: PropTypes.object,
    children: PropTypes.node
  };

  const [loaded, updateLoaded] = useState(false);

  // Get our fields for the corresponding fieldset.
  const [fetchFieldSet, { loading, called, data }] = useLazyQuery(fetchFields, {
    displayName: `fetchFieldSet ${id}`,
    client: getDataCacheService(),
    variables: {data: {fields: variables.fields}},
    onCompleted: (data) => {
      if (!loaded && data.fetchFields && data.fetchFields.length > 0) {
        updateLoaded(true);
      }
    }
  });

  /**
   * Execute our lazyQuery before rendering.
   */
  useEffect(
    () => {
      if (!loaded && !called && !loading) {
        fetchFieldSet();
      }
    },
    [loaded,called,loading]
  );

  const renderFieldGroup = useCallback(
    () => {
      if (loaded) {
        if (type) {
          // Allow lower case names to be passed and convert the first character to a more friendly class name.
          const typeClassName = type.charAt(0).toUpperCase() + type.slice(1);
          if ( typeClassName in CustomFieldGroups ) {
            return CustomFieldGroups[typeClassName]({...props, fields: data.fetchFields});
          } else if (typeClassName in FieldGroups ) {
            return FieldGroups[typeClassName]({...props, fields: data.fetchFields});
          }
        }
        return FieldGroups['Default']({...props, fields: data.fetchFields});
      }
      return null;
    },
    [loaded, data]
  );

  return( renderFieldGroup() );
}


export default FieldGroup;
