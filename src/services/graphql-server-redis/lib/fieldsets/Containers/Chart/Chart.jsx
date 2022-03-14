import React, { useState, useCallback, useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import Container from 'lib/fieldsets/Containers/Container';
import ChartType from './ChartType';
import { useStatus, usePortals } from 'lib/fieldsets/Hooks';

/**
 * This is the generic Diagram component which is used to build diagram containers.
 * This component initializes the data cache with diagram data, as well as setting up the underlying coordinate system for tracking diagram interactions.
 */
const Chart = ({id, name, type, meta, visible = false, children}) => {
  const propTypes = {
    id: PropTypes.string.isRequired,
    name: PropTypes.string,
    type: PropTypes.string.isRequired,
    meta: PropTypes.object,
    visible: PropTypes.bool,
    children: PropTypes.node
  };

  const [{stage, status, message}, updateStatus] = useStatus();
  const [loaded, updateLoaded] = useState(false);
  const portals = usePortals();
  const viewerPortal = useRef(portals.viewer.portalRef);

  useEffect(
    () => {
      if ( ! loaded ) {
        if ( 'loaded' === status && 'container' === stage ) {
          updateLoaded(true);
          updateStatus('rendering', `Rendering ${id}`, 'chart');
        }
      }
    },
    [status]
  );

  const renderDiagram = useCallback(
    () => {
      if (loaded) {
        return(
          ReactDOM.createPortal(
            <div id={id} className="viewer-container">
              <ChartType
                id={id}
                name={name}
                type={type}
              >
                {children}
              </ChartType>
            </div>,
            portals.viewer.portalRef
          )
        );
      }
      return null;
    },
    [loaded]
  );

  // TODO: Add in an underlying canvas based X,Y coordinate system which should be more performant for tracking set centers.
  return (
    <React.Fragment>
      <Container
        id={id}
        name={name}
        type={'Chart'}
        view={type}
        meta={meta}
        visible={visible}
      >
        {renderChart()}
      </Container>
    </React.Fragment>
  );
}

export default Chart;
