import {usePromiseQueue} from './Promises';
import {PromiseHandler} from '../Handlers/Promise';

export const useInputEvents = (onChange) => {
  const queue = usePromiseQueue();

  const delay = n => new Promise(resolve => setTimeout(resolve, n));

  const handleChange = (value, event) => {
    queue.clearPendingPromises();
    const waitForChange = PromiseHandler(delay(1000));
    queue.appendPendingPromise(waitForChange);

    return waitForChange.promise
      .then(() => {
        queue.removePendingPromise(waitForChange);
        onChange(value, event);
      })
      .catch(errorInfo => {
        queue.removePendingPromise(waitForChange);
        if (!errorInfo.isCanceled) {
          throw errorInfo.error;
        }
      });
  };

  return [ handleChange ];
};
