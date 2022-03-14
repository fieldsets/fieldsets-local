import gql from 'graphql-tag';
import { fragments } from '../fragments';

/**
 * Fetch all the fields of a fieldset
 */
export const fetchFields = gql`
  query FetchFields( $data: Array ) {
    fetchFields( data: $data ) @client(always: true) {
      ...field
    }
  }
  ${fragments.field}
`;

export const updateField = gql`
  mutation UpdateFields( $data: Array ) {
    updateFields( data: $data ) @client(always: true) {
      ...field
    }
  }
  ${fragments.field}
`;

export const fetchField = gql`${fragments.field}`;
