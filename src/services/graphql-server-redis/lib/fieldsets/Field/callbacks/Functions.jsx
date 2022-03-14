import React, { createContext, useMemo, useState } from 'react';
import { getNumericValue } from 'lib/fieldsets/utils';
import {CustomFunctions} from 'utils/callbacks';

// Our contexts.
export const FunctionsContext = createContext({});

export const Functions = (props) => {

  /**
   * our default set of functions on our fields and their values.
   * If you'd like to add custom callbacks, use the `useFunctions` hook.
   */
  const functions = useMemo(
    () => {
      let custom = CustomFunctions();
      custom = (custom) ? custom : {};
      return(
        {
          cast: (field, type) => {
            const lctype = type.toLowerCase()
            switch (lctype) {
              case 'number':
              case 'numeric':
              case 'num':
              case 'float':
              case 'int':
              case 'integer':
              case 'decimal':
              case 'currency':
                return getNumericValue(field, 'cast');
                break;
              case 'string':
              case 'char':
              case 'varchar':
              case 'text':
                return String(field);
                break;
              default:
                try {
                  throw new Error(`Function "cast": ${typeof type} is not a supported type for casting.`);
                } catch (e) {
                  console.error( e.message );
                  return field;
                }
                break;
            }
          },
          sum: (data) => {
            // Add all data values.
            if (data && data.length > 0) {
              let sum = 0;
              data.map( (field) => {
                const number = getNumericValue(field, 'sum');
                sum = sum + number;
              });
              return sum;
            }
          },
          diff: (data) => {
            // Will subtract remaining data values from first data value.
            if (data && data.length > 0) {
              let diff = getNumericValue(data[0], 'diff');
              data.slice(1).map( (field) => {
                const number = getNumericValue(field, 'sum');
                diff = diff - number;
              });
              return diff;
            }
          },
          avg: (data) => {
            // Returns the average of all data values.
            if (data && data.length > 0) {
              let sum = 0;
              let count = 0;
              data.map( (field) => {
                const number = getNumericValue(field, 'sum');
                sum = sum + number;
                count = count + 1;
              });
              return sum/count;
            }
          },
          ...custom
        }
      );
    },
    []
  );


  return (
    <FunctionsContext.Provider value={useState(functions)}>
      {props.children}
    </FunctionsContext.Provider>
  )
}
