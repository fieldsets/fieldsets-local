import React from 'react';

const Html = ({id, className, name, active, visible, variables, children}) => {
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

  const viewboxX = (variables.attributes.viewbox && variables.attributes.viewbox.x) ? variables.attributes.viewbox.x : textX;
  const viewboxY = (variables.attributes.viewbox && variables.attributes.viewbox.y) ? variables.attributes.viewbox.y : textY;

  const visibleClass = visible ? 'shown' : 'hidden';

  // Lowercase view for className
  const view_lower = variables.view.toLowerCase();

  return (
    <foreignObject
      x={viewboxX}
      y={viewboxY}
      width={variables.attributes.width}
      height={variables.attributes.height}
      textAnchor="middle"
      className={`view-text view-${view_lower}-text ${visibleClass}`}
    >
      {children}
    </foreignObject>
  );
}

export default Html;
