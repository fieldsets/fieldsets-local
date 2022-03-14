/**
 * This file contains ROOT queries that represent the current focus of the the application.
 * Root level data will be written to triggered by events in the application that cause the fragments to be written to and then, these queries will be refetched.
 */
 import gql from 'graphql-tag';

 export const fetchFocus = gql`
  query FetchFocus {
    focus @client(always: true) {
      id
      focusID
      focusGroup
      container {
        containerID
        type
      }
      type
      depth
      expanded
      center {
        x
        y
      }
      zoom {
        scale
      }
    }
  }
`;

 export const updateFocus = gql`
  mutation UpdateFocus($data: Array) {
    updateFocus(data: $data) @client(always: true)
  }
`;
