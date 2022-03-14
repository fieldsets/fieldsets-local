import React from 'react';

const SVGLabel = ({id, className, name, active, visible, variables, children}) => {
  // If no label has been set don't render;
  if (! name ) return null;

  const defaults = {
    ratio: 1.2,
    textSize: 0.45
  }

  const center = variables.center;
  let { textX, textY } = {...defaults, ...variables.attributes};

  const centerX = center.x;
  const centerY = center.y;

  textX = (textX) ? textX : centerX;
  textY = (textY) ? textY : centerY;

  const visibleClass = visible ? 'shown' : 'hidden';

  // Lowercase view for className
  const view_lower = variables.view.toLowerCase();

  return (
    <text
      x={textX}
      y={textY}
      textAnchor="middle"
      className={`view-text view-${view_lower}-text ${visibleClass}`}
    >
      <tspan
        id={`${id}-legend`}
        x={textX}
        dy="0em"
        className={`view-legend view-${view_lower}-legend`}
      >
        {name}
      </tspan>
      {children}
    </text>
  );
}

export default SVGLabel;
