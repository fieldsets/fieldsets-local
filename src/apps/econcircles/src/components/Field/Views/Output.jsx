import React from 'react';

const Output = ({id, field, label = false, events}) => {
  const depString = field.children.join(" ");
  label = (label) ? label : field.name;
  return (
    <div
      id={`${id}-output`}
      className={'field-output'}
    >
      <label htmlFor={id}>
        {label}
      </label>
      <output
        id={id}
        name={id}
        value={field.value}
        htmlFor={depString}
        className={`field fieldtype-${field.type}`}
        {...events}
      >
        {field.value}
      </output>
    </div>
  );
}

export default Output;
