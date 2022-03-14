import React, { useEffect, useMemo, useCallback, useState, useRef, forwardRef, useTransition } from 'react';
import * as Groups from './Groups';
import * as CustomGroups from 'components/Sets/Groups';
import { useInputEvents, useClickEvents, useController } from 'lib/fieldsets/Hooks';
import { Fetch, Update } from 'lib/fieldsets/DataCache/calls';

const SetGroup = (props, ref) => {
  const {id, view, type, group = 'group'} = {...props}
  const cacheKey = {
    id: id,
    target: 'meta',
    type: type,
    filter: 'attributes'
  };

  const [applyChange, pending] = useTransition({timeoutMs: 5000});
  const [{fieldsets}, controller] = useController();

  const [attributes, updateAttributes] = useState( () => {
    return Fetch({...cacheKey});
  });

  const [rendered, updateRendered] = useState(false);

  const [handleOnChange] = useInputEvents(props.onChange);
  const [handleClick, handleDoubleClick] = useClickEvents(props.onClick, props.onDoubleClick);
  const setRef = useRef(ref);

  let events = {};
  if ( props.onClick || props.onDoubleClick ) {
    events.onClick = handleClick;
    events.onDoubleClick = handleDoubleClick;
  }

  if (props.onEnter && props.onExit) {
    events.onPointerEnter = props.onEnter;
    events.onPointerLeave = props.onExit;
  }

  // Set the viewbox after the render for next load.
  useEffect(
    () => {
      if (setRef.current) {
        if ('parent' === group) {
          getGroupViewBox();
        } else if ('children' === group) {
          getGroupCenter();
        }
      }
    },
    [setRef.current, group]
  );

  useEffect(
    () => {
      if ( attributes.viewbox || attributes.center) {
        applyChange(() => {
          updateRendered(true);
          // Let the view know we have calculated the set viewbox and center for rendering fields.
          controller.updateFieldSetStatus(id, 'ready');
        });
      }
    },
    [attributes]
  );

  const getGroupViewBox = useCallback(
    () => {
      let vb = null;
      if (attributes && attributes.viewbox) {
        vb = {...attributes.viewbox};
      } else {
        applyChange(() => {
          if ('group' !== group ) {
            // Currently works with SVG. Need to set this up to work with html getBoundingClientRect()
            const bbox = setRef.current.getBBox();
            vb = { x: bbox.x, y: bbox.y, width: bbox.width, height: bbox.height, __typename: 'JSONObject' };
            if (vb && vb.width > 0 && vb.height > 0) {
              const newAttributes = {
                ...attributes,
                width: vb.width,
                height: vb.height,
                viewbox: {...vb}
              };
              Update({...cacheKey}, {...newAttributes});
              updateAttributes({...newAttributes});
            }
          }
        });
      }
      return {...vb};
    },
    [setRef.current, group, attributes]
  );

  const getGroupCenter = useCallback(
    () => {
      if (attributes && attributes.group && attributes.group.center) {
        return attributes.group.center;
      } else {
        const bbox = getGroupViewBox();
        if (bbox && bbox.width && bbox.height) {
          const rx = bbox.width / 2;
          const ry = bbox.height / 2;
          const cx = bbox.x + rx;
          const cy = bbox.y + ry;
          const center = {
            x: cx,
            y: cy,
            __typename: 'Center'
          };
          const boxCenter = { width: bbox.width, height: bbox.height, radiusX: rx, radiusY: ry, center: {...center}, __typename: 'JSONObject' };
          applyChange(() => {
            const newAttributes = {
              ...attributes,
              group: { ...boxCenter }
            };
            Update({...cacheKey}, {...newAttributes});
            updateAttributes({...newAttributes});
          });
          return {...boxCenter};
        }
      }
    },
    [setRef.current, group, attributes]
  );

  if (props.view) {
    // Allow lower case names to be passed and convert the first character to a more friendly class name.
    const setgroupClassName = props.view.charAt(0).toUpperCase() + props.view.slice(1);
    if ( setgroupClassName in CustomGroups ) {
      return CustomGroups[setgroupClassName]({...props, events}, setRef);
    } else if ( setgroupClassName in Groups ) {
      return Groups[setgroupClassName]({...props, events}, setRef);
    }
  }
  return Groups['Default']({...props, events}, setRef);
}

export default forwardRef(SetGroup);
