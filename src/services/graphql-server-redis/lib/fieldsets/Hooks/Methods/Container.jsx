import {useContext} from 'react';
import { ContainerContext } from 'lib/fieldsets/Containers/Container';
export const useContainer = () => useContext(ContainerContext);
