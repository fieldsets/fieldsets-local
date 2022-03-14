import {useContext} from 'react';
import { PortalContext } from '../Handlers/Portals';
export const usePortals = () => useContext(PortalContext);
