import {useContext} from 'react';
import { FunctionsContext } from 'lib/fieldsets/Field/callbacks/Functions';
export const useFunctions = () => useContext(FunctionsContext);
