import React, { Suspense, useLayoutEffect, useEffect, useState, useMemo, useCallback, useTransition, useRef } from 'react';
import PropTypes from 'prop-types';
import {useFocus, useStatus, useController} from 'lib/fieldsets/Hooks';
import { Fetch } from 'lib/fieldsets/DataCache/calls';

const SetGroup = React.lazy(() => import('lib/fieldsets/Set/SetGroup'));
const SubSet = React.lazy(() => import('lib/fieldsets/Set/SubSet'));
const SetView = React.lazy(() => import('lib/fieldsets/Set/SetView'));

/**
 * Root Sets are state data components that represent top level grouping of set data and a users interactions with that data.
 * Each root set will check its own children set data and will iteratively call itself on it's children children.
 */
const Set = ({ id, children }) => {
  const stageName = 'render';
  // The lifecycle stages that must be complete before rendering.
  const stageDeps = ['defaults', 'datacache', 'controller', 'container'];

  const [isActive, updateActive] = useState(false);

  const [current, updateStatus, lifecycle] = useStatus();
  const [{stage, status, complete}, setStatus] = useState({stage: '', status: '', message: '', complete: false});
  const [initialized, updateInitialized] = useState(false);

  const [applyChange, pending] = useTransition({timeoutMs: 5000});
  const [focus, updateFocus] = useFocus();
  const [{fieldsets}, controller] = useController();

  /**
   * Stateful latest data for this set from our cache
   */
  const [fieldset, updateFieldSet] = useState({id: null, children: [], parent: '', meta: {id: null, data: {}}});
  const [depth, updateDepth] = useState(0);

  const setRef = useRef({});

  /**
   * A separate callback for metadata.
   */
  const fetchSetMeta = useCallback(
    () => {
      if (isReady && stage === stageName) {
        return Fetch({ id: id, target: 'meta'});
      }
    },
    [isReady, stage]
  );

  /**
   * Fetch the latest values of this set from the cache fragments.
   */
  const fetchSetData = useCallback(
    () => {
      if (isReady && stage === stageName) {
          const fetchset = Fetch({ id: id, target: 'fieldset'});
          const fetchmeta = fetchSetMeta();
          const updatedFieldset = {
            ...fetchset,
            meta: {
              ...fetchmeta
            }
          };
          applyChange( () => {
            updateFieldSet({...updatedFieldset});
            controller.addFieldSet(id, fetchmeta.data.view, fetchmeta.type, true);
          });
          return {...updatedFieldset};
      }
    },
    [isReady, stage, fetchSetMeta]
  );

  /**
   * If the global stage is set to render, we then pass off status management to the this rendered setroot.
   */
  useLayoutEffect(
    () => {
      if (stageName === current.stage) {
        applyChange( () => {
          setStatus({...current});
        });
      }
    },
    [current]
  );

  /**
   * Tells us if the controller loaded all of this container's dependencies.
   */
  const isReady = useMemo(
    () => {
      if (complete) {
        return true;
      }
      let depsMet = true;
      for (const dep of stageDeps) {
        if ( lifecycle[dep] ) {
          depsMet = lifecycle[dep].complete;
        } else {
          depsMet = false;
        }
        if (!depsMet) {
          break;
        }
      }
      return depsMet;
    },
    [lifecycle]
  );

  useEffect(
    () => {
      if ( isReady && ! complete && stage === stageName ) {
        applyChange( () => {
          switch (status) {
            case 'initializing':
              setStatus({stage, status: 'initialized', message: `Set ${id} initialized for render`, complete: false});
              break;
            case 'initialized':
              // Switch the global state to rendering.
              updateStatus('rendering', `Rendering ${id} set & subsets`);
              break;
            case 'rendering':
              // For any subsets loaded after the top level set, we simply need to
              updateInitialized(true);
              // Refetch data when rendering starts
              fetchSetData(id);
              break;
            default:
              break;
          }
        });
      }
    },
    [isReady, stage, status, complete]
  );

  const setActive = useCallback(
    () => {
      applyChange( () => {
        updateActive(true);
      });
    },
    []
  );

  const setInactive = useCallback(
    () => {
      applyChange( () => {
        updateActive(false);
      });
    },
    []
  );

  const subset = useMemo(
    () => {
      if (isReady && fieldset && fieldset.children && fieldset.children.length > 0) {
        return (
          <SubSet
            id={ `${fieldset.id}` }
            key={ `${fieldset.id}-subset` }
            data={ {...fieldset} }
          />
        );
      }
      return null;
    },
    [isReady, fieldset]
  );

  if (!isReady || !initialized) {
    return null;
  }

  // Build a nested Set Component render tree.
  return(
    <Suspense>
      <SetGroup
        id={`${id}`}
        key={`${id}-group`}
        type={(fieldset.type) ? fieldset.type : 'fieldset'}
        group={'group'}
        view={fieldset.meta.data.view}
        className={`set-group ${fieldset.id}-group${(isActive)? ' active' : ''}`}
        onEnter={setActive}
        onExit={setInactive}
      >
        <Suspense>
          <SetGroup
            id={`${id}`}
            key={`${id}-parent`}
            type={fieldset.type}
            group={'parent'}
            view={fieldset.meta.data.view}
            active={isActive}
            className={`view-${fieldset.meta.data.view} set-parent ${id}-group${(isActive)? ' active' : ''}`}
            onClick={() => {
              if ( id !== focus.focusID ) {
                updateFocus({ action: 'focus', data: { id: 'current', focusID: id, focusGroup: fieldset.parent, type: fieldset.type, center: fieldset.meta.data.center, zoom: fieldset.meta.data.zoom, depth: fieldset.meta.data.depth, expanded: false }});
              }
            }}
            onDoubleClick={() => {
              updateFocus({ action: 'expand', data: { id: 'current', focusID: id, focusGroup: fieldset.parent, type: fieldset.type, center: fieldset.meta.data.center, zoom: fieldset.meta.data.zoom, depth: fieldset.meta.data.depth, expanded: true }});
            }}
            onEnter={() => {updateActive(true)}}
            onExit={() => {updateActive(false)}}
            ref={setRef}
          >
            <Suspense>
              <SetView
                id={id}
                view={fieldset.meta.data.view}
                active={isActive}
                variables={{
                  ...fieldset.meta.data,
                  name: fieldset.name,
                  depth: depth,
                  parent: fieldset.parent,
                  visible: true, //TODO: Pull from controller.
                  view: fieldset.meta.data.view,
                  fields: fieldset.fields
                }}
              />
            </Suspense>
          </SetGroup>
        </Suspense>
        {subset}
      </SetGroup>
    </Suspense>
  );
}
Set.propTypes = {
  id: PropTypes.string.isRequired
};

export default Set;
