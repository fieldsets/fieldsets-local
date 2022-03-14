/**
 * Meta sets are sets that contain field data that is never rendered.
 * These types are useful for tracking data within your app, but that will not require a snapshot on save to persistant remote storage.
 */
 import gql from 'graphql-tag';
 import { fragments } from '../fragments';

export const updateMeta = gql`
  mutation UpdateMeta($id: ID!) {
    updateMeta(id: $id) @client(always: true)
  }
`;

export const fetchMeta = gql`${fragments.meta}`;
