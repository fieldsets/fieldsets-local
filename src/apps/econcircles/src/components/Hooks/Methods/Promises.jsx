import { useRef } from 'react';

/**
 * Handle Cancelation of promises. Usefull for handling double clicks or other user interactions.
 */
export const usePromiseQueue = () => {
  const pendingPromises = useRef([]);

  const appendPendingPromise = (promise) => {
    pendingPromises.current = [...pendingPromises.current, promise];
  }

  const removePendingPromise = (promise) => {
    pendingPromises.current = pendingPromises.current.filter(p => p !== promise);
  }

  const clearPendingPromises = () => {
    pendingPromises.current.map(p => p.cancel());
  }

  const queue = {
    appendPendingPromise,
    removePendingPromise,
    clearPendingPromises,
  };

  return queue;
};
