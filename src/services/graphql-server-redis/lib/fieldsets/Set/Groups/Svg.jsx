import React from 'react';

const Svg = ({id, view, type = 'fieldset', group = 'group', active = false, className, events = {}, children}, ref) => {

  if ('parent' === group ) {
    return (
      <svg
        id={`${id}`}
        className={`${className}`}
        {...events}
        ref={ref}
      >
        {children}
      </svg>
    );
  }

  return(
    <g
      id={`${id}-${group}`}
      className={`${className}`}
      {...events}
      ref={ref}
    >
      {children}
    </g>
  );
}
export default Svg;
