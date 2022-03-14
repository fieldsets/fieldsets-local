import {useContext} from 'react';
import { DefaultsContext } from '../Handlers/Defaults';
export const useDefaults = () => useContext(DefaultsContext);
