import {useContext} from 'react';
import { ControllerContext } from 'lib/fieldsets/Containers/Controller';
export const useController = () => useContext(ControllerContext);
