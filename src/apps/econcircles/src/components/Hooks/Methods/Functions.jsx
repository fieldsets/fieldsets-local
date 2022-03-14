import {useContext} from 'react';
import { FunctionsContext } from 'components/Field/callbacks/Functions';
export const useFunctions = () => useContext(FunctionsContext);
