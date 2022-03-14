import gql from 'graphql-tag';
import { fragments } from '../fragments';

/**
 * Fetch All
 */
export const fetchAccounts = gql`
  query FetchAccounts {
    fetchAccounts {
      ...member
    }
  }
  ${fragments.account}
`;

/**
 * Fetch All
 */
export const fetchMembers = gql`
  query FetchMembers {
    fetchMembers {
      ...member
    }
  }
  ${fragments.member}
`;

/**
 * Fetch All
 */
export const fetchRoles = gql`
  query FetchRoles {
    fetchRoles {
      ...role
    }
  }
  ${fragments.role}
`;

export const updateMember = gql`
  mutation UpdateMember($data: Array) {
    updateMember(data: $data) @client
  }
  ${fragments.member}
`;

export const updateAccount = gql`
  mutation UpdateAccount($data: Array) {
    updateAccount(data: $data) @client
  }
  ${fragments.account}
`;

export const updateRole = gql`
  mutation UpdateRole($data: Array) {
    updateRole(data: $data) @client
  }
  ${fragments.role}
`;

/**
 * Fetch by id.
 */
export const fetchRole = gql`${fragments.role}`;
export const fetchAccount = gql`${fragments.account}`;
export const fetchMember = gql`${fragments.member}`;
