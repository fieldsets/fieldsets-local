import {useContext} from 'react';
import { ControllerContext } from 'components/Containers/Controller';
export const useController = () => useContext(ControllerContext);
