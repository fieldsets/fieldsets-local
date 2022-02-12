import React from 'react';

const Text = ({id, view, field, events}) => {
  return (
    <div
      id={`${id}-text`}
      className={'field-text'}
    >
      <label for={id}>{field.name}</label>
      <input
        id={id}
        name={id}
        defaultValue={(field.value > 0) ? field.value : ''}
        className={`field fieldtype-${field.type}`}
        type="text"
        {...events}
      />
    </div>
  );
}

export default Text;
