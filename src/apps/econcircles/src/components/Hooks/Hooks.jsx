import React from 'react';
import { Functions } from '../Field/callbacks/Functions';
import { Focus } from './Handlers';

/**
 * This is our hook component which sets up the required contexts for our core hooks.
 * Hooks placed in this componenet will have access to the datacache.
 */
const Hooks = (props) => {
  return (
    <Focus>
      <Functions>
        {props.children}
      </Functions>
    </Focus>
  );
};

export default Hooks;
