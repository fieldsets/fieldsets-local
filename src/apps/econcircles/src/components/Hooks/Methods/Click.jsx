import {usePromiseQueue} from './Promises';
import {PromiseHandler} from '../Handlers/Promise';

export const useClickEvents = (onClick, onDoubleClick) => {
  const queue = usePromiseQueue();

  const delay = n => new Promise(resolve => setTimeout(resolve, n));

  const handleClick = (e) => {
    queue.clearPendingPromises();
    const waitForClick = PromiseHandler(delay(300));
    queue.appendPendingPromise(waitForClick);

    return waitForClick.promise
      .then((e) => {
        queue.removePendingPromise(waitForClick);
        onClick(e);
      })
      .catch(errorInfo => {
        queue.removePendingPromise(waitForClick);
        if (!errorInfo.isCanceled) {
          throw errorInfo.error;
        }
      });
  };

  const handleDoubleClick = (e) => {
    queue.clearPendingPromises();
    onDoubleClick(e);
  };

  return [ handleClick, handleDoubleClick ];
};
