/**
 * CONTAINERS
 * Containers are Parent FieldSets that serve as a collection of Field Sets that create the UI.
 * The FieldSets framework was built originally using the core containers Diagram, Interface, Sheet & Account, but this can be expanded to include any custom collection of fieldsets.
 * The framework tracks the User focus, and will load lists of the fields, sets and metdata needed to render the current visualization.
 * The graphql queries below aid the focus handler in updated and fetching from the root query the current actively focused container.
 */

import gql from 'graphql-tag';
import { fragments } from '../fragments';

/**
 * Fetch Fieldsets from Root Query Active Focus Container.
 */
export const fetchContainer = gql`
  query FetchContainer {
    container @client(always: true) {
      id
      name
      type
      parent
      children
      fields
    }
  }
`;

/**
 * Update the Root Query Active Focus Container.
 */
export const updateContainer = gql`
  mutation UpdateContainer($data: Array) {
    updateContainer(data: $data) @client(always: true) {
      container @client(always: true) {
        id
        name
        type
        parent
        children
        fields
      }
    }
  }
`;


/**
 * Fetch fieldsets from active container.
 * Currently fieldsets are read only in the application and should be defined in your data architecture (either dd or json format)
 */
export const fetchContainerData = gql`
  query FetchContainerData {
    fetchContainerData @client(always: true) {
      ...fieldset
    }
  }
  ${fragments.fieldset}
`;
