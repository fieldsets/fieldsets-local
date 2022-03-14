/**
 * A label Sheet only displays fields that are always visible.
 */
 import React from 'react';
 import PropTypes from 'prop-types';
 import { Field } from 'lib/fieldsets';

const List = ({id, view, type = 'list', fields}) => {
  return(
    <ul
      id={`${id}-${type}`}
    >
      {
        fields.map((field) => {
          return(
            <li
              key={ `${field.id}-item` }
              className={`${type}-item`}
            >
              <Field
                id={ field.id }
                key={ field.id }
                view={(view) ? view : field.type}
                data={ field }
              />
            </li>
          );
        })
      }
    </ul>
  );
}
List.propTypes = {
  id: PropTypes.string.isRequired,
  view: PropTypes.string,
  type: PropTypes.string,
  fields: PropTypes.array.isRequired
}

export default List
