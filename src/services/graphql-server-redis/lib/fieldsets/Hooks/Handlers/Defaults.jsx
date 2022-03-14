import React, { createContext, useMemo, useState, useEffect, useLayoutEffect, useTransition } from 'react';
import { rootQueryDefaults, fragmentDefaults, SetTypes, MetaTypes, FieldTypes } from 'lib/fieldsets/graphql/defaults';
import {useStatus} from 'lib/fieldsets/Hooks';

// Our context.
export const DefaultsContext = createContext([]);

const Defaults = (props) => {
  const stageName = 'defaults';
  const [current, updateStatus, lifecycle] = useStatus();
  const [{stage, status, message, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});
  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  useEffect(
    () => {
      if (! complete && stageName === current.stage ) {
        applyChange( () => {
          setStatus({...current});
        });
      }
    },
    [current]
  );

  /**
   * Our default values used throughout our code base.
   * If you'd like to add custom defaults or alter the current values, use the `useDefaults()` hook.
   */
  const defaultValues = useMemo(
    () => {
      return(
        {
          rootQuery: {...rootQueryDefaults},
          fragments: {...fragmentDefaults},
          setTypes: [...SetTypes],
          metaTypes: [...MetaTypes],
          fieldTypes: [...FieldTypes]
        }
      );
    },
    []
  );

  const [defaults, updateDefaults] = useState({...defaultValues});

  // Defaults initialize on their own.
  useEffect(
    () => {
      applyChange( () => {
        updateStatus('initializing', 'Initializing default values', stageName);
      });
    },
    []
  );

  /**
   * Set a stage and status after render that allows to to initialize application specific defaults.
   */
  useEffect(
    () => {
      if ( ! pending ) {
        applyChange( () => {
          if ( stageName === stage && 'initializing' === status ) {
            updateStatus('complete', 'Default values initialized', stageName, true);
          }
        });
      }
    },
    [stage, status, pending]
  );

  /**
   * Once we are inside out context provider, we can utilize this Handler's state.
   * For this context, we allow mergeing of default state by default, with the option to overwrite.
   */
  const setDefaultValues = (newDefaults, overwrite = false) => {
    let newValues;
    if (overwrite) {
      newValues = {...newDefaults};
    } else {
      newValues = {...defaults, ...newDefaults}
    }
    applyChange(() => {
      updateDefaults({...newValues});
    });
    return {...newValues};
  }

  return (
    <DefaultsContext.Provider value={[ defaults, setDefaultValues ]}>
      {props.children}
    </DefaultsContext.Provider>
  );
}

export default Defaults;
