import React, { Suspense, useEffect, useState, useTransition } from 'react';
import {CustomLabel, DefaultLabel} from './Labels';
import * as CustomLabels from 'components/Sets/Labels';
import { useController } from 'lib/fieldsets/Hooks';

const SetLabel = (props) => {
  const [{fieldsets}, controller] = useController();
  const [ready, updateReady] = useState(false);
  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  /**
   * Use the controller to check when we are ready to render any fields
   */
  useEffect(
    () => {
      if (fieldsets && fieldsets[props.id] && 'ready' === fieldsets[props.id].status ) {
        applyChange(() => {
          updateReady(true);
        })
      }
    },
    [fieldsets]
  );

  if (!ready) {
    return null;
  }

  if (props.type) {
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const setlabelClassName = props.type.charAt(0).toUpperCase() + props.type.slice(1);
    if ( setlabelClassName in CustomLabels ) {
      return (
        <Suspense>
          <CustomLabel
            {...props}
          >
            {CustomLabels[setlabelClassName]({...props})}
          </CustomLabel>
        </Suspense>
      );
    }
  }
  return (
    <Suspense>
      <DefaultLabel
        {...props}
      >
        {props.children}
      </DefaultLabel>
    </Suspense>
  );
}

export default SetLabel;
