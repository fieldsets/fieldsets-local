import React, {createContext, useState, useEffect, useTransition} from 'react';

export const StatusContext = createContext([]);
/**
 * Our status handler component tracks the runtime lifecycle of an application concurrently and allows us to run side effects for concurrent components via our controller.
 * There are are series of stages within the fieldsets application lifecycle.
 * Status can be reused between stages, but make sure you are checking both status and stage when firing off any custom effects.
 */

const Status = (props) => {
  const [lifecycle, updateLifecycle] = useState({[props.stage]: {stage: props.stage, status: props.status, message: props.message, complete: false}});
  const [stage, updateStage] = useState(props.stage);
  const [message, updateMessage] = useState(props.message);
  const [status, updateStatus] = useState(props.status);
  const [applyChange, pending] = useTransition({timeoutMs: 5000});

  const setStatus = (newStatus = 'default', newMessage = '', newStage = false) => {
    applyChange( () => {
      if ( ! newStage ) {
        newStage = stage;
      }
      // Check if lifecyle is complete.
      if (newStage !== stage) {
        updateStage(newStage);
      }
      if (newMessage !== message) {
        updateMessage(newMessage);
      }
      if (newStatus !== status) {
        updateStatus(newStatus);
      }
    });
  }

  useEffect(
    () => {
      let complete = false;
      if ('complete' === status) {
        complete = true;
      }
      applyChange( () => {
        updateLifecycle({
          ...lifecycle,
          [stage]: {stage, status, message, complete}
        })
      });
    },
    [status, message, stage, pending]
  );

  /**
   * For debugging, uncomment this hook which fires on every status change.
   * This is a good way to tell what the status and stage is of the current application and can help with debugging.
   */
  useEffect(
    () => {
      if ( lifecycle[stage] ) {
        console.log(lifecycle[stage]);
      }
    },
    [lifecycle]
  );

  return (
    <StatusContext.Provider value={[{...lifecycle[stage]}, setStatus, lifecycle]}>
      {props.children}
    </StatusContext.Provider>
  );
}
export default Status
