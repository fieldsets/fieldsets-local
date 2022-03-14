import gql from 'graphql-tag';
import { meta } from './meta';
import { field } from './field';
import { account, member, role } from './account';
import { fieldset } from './fieldset';

export const fragments = {
  all: gql`
    ${field}
    ${fieldset}
    ${meta}
    ${member}
    ${account}
    ${role}`,
  field: gql`
    ${field}
    ${meta}`,
  fieldset: gql`
    ${fieldset}
    ${meta}`,
  member: gql`
    ${account},
    ${member},
    ${role},
    ${meta}`,
  account: gql`
    ${account},
    ${member},
    ${role},
    ${meta}`,
  role: gql`
    ${account},
    ${member},
    ${role},
    ${meta}`,
  meta: gql`
    ${meta}`,
}
