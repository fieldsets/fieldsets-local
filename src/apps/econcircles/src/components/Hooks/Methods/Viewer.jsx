import {useState, useEffect} from 'react';

export const useViewerDimensions = () => {
  const getViewerDimensions = () => {
    const { innerWidth: width, innerHeight: height } = window;
    return {
      width,
      height
    };
  }

  const [viewerDimensions, setViewerDimensions] = useState(() => {
    return getViewerDimensions();
  });

  useEffect(() => {
    const handleResize = () => {
      setViewerDimensions( getViewerDimensions() );
    }

    window.addEventListener('resize', handleResize);

    return( () => { return window.removeEventListener('resize', handleResize) } );
  }, []);

  return viewerDimensions;
}
