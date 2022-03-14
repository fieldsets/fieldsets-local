import React from 'react';

/**
 * This is simply an empty interface that renders it's children.
 */
const Default = (props) => {
  return (
    <React.Fragment>
      {props.children}
    </React.Fragment>
  );
}

export default Default;
