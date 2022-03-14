import gql from '@apollo/client';
import { fragments } from '../fragments';

export const fetchFieldSet = gql`${fragments.fieldset}`;
