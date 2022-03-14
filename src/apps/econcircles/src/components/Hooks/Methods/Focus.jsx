import {useContext} from 'react';
import { FocusContext } from '../Handlers/Focus';
export const useFocus = () => useContext(FocusContext);
