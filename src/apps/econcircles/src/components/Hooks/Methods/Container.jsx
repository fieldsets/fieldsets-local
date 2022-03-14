import {useContext} from 'react';
import { ContainerContext } from 'components/Containers/Container';
export const useContainer = () => useContext(ContainerContext);
