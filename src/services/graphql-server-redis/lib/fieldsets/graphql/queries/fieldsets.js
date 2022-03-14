import gql from 'graphql-tag';
import { fragments } from '../fragments';

export const fetchFieldSet = gql`${fragments.fieldset}`;
