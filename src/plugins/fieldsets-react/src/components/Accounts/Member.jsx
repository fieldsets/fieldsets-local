/**
 * Accounts & members are a unique set type that can be assigned as owners of fieldset snapshots.
 * Members can also be given roles that can be used for capabilities within the app.
 */
 /**
  * Accounts & members are a unique set type that can be assigned as owners of fieldset snapshots.
  * Members can also be given roles that can be used for capabilities within the app.
  */
 import React, { useEffect, useState } from 'react';
 import PropTypes from 'prop-types';
 import {Initialize} from '../DataCache/calls';

const Member = ({id, name, attributes, children}) => {
  const [status, updateStatus] = useState('initializing');
  const [data, updateData] = useState({
    id: id,
    fields: {},
    sets: {},
    meta: {}
  });

  /**
   * Certain applications will have data that varies per account.
   * Accounts are a unique fieldset in that their children members may be assigned as owners of other fieldset snapshots.
   * This interface component allows for loading of an owner account and it members here.
   */

  useEffect( () => {
      if ( 'initializing' === status ) {
        const initData = Initialize({key: id, id: id, target: 'member'});
        updateMemberData(initData);
      }
      updateStatus('ready');
    },
    [status,id]
  );

  /**
   * Merge the updated data with current diagram data.
   */
  const updateMemberData = (newData) => {
    updateStatus('update');
    updateData( prevData => {
      return ({
        ...prevData,
        ...newData
      });
    });
  }

  /**
   * Wait for our initial data load, otherwise we won't be blocked on re-renders as the diagram renders are managed by data states and asyncrhonous updates to the data cache.
   */
  if ( 'ready' !== status ) {
    // TODO: Add in nicer animation for initializating.
    return <div>Loading....</div>;
  }

  return (
    <React.Fragment key={id}>
      <div data={data}/>
    </React.Fragment>
  );
}

Member.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string
};

export default Member;
