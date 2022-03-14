// The default root query values. If you'd like to add to this const, use the `useDefaults()` Hook.
export const rootQueryDefaults = {
  focus: {
    id: 'current',
    focusID: 'default',
    focusGroup: '',
    type: '',
    container: {
      containerID: 'default',
      type: 'container',
      __typename: 'JSONObject'
    },
    expanded: false,
    center: { x: 0, y: 0, __typename: 'JSONObject' },
    depth: 0,
    zoom: { scale: 1, __typename: 'JSONObject' },
    __typename: 'Focus'
  },
  container: null
};

/**
 * This const contains the default data shape and values for our graphql query fragments.
 * We can use these when we initialize fragments that have not been created.
 * If you'd like to alter these values, use the `useDefaults()` Hook.
 */
export const fragmentDefaults = {
  account: {
    name: '',
    type: 'account',
    parent: [],
    children: [],
    members: [],
    meta: {
      type: 'account',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'Account'
  },
  field: {
    name: '',
    description: '',
    parent: '',
    fieldsets: [],
    value: null,
    type: 'default',
    callback: false,
    owner: '',
    order: 0,
    children: [],
    meta: {
      type: 'field',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'Field'
  },
  fieldset: {
    name: '',
    type: 'fieldset',
    parent: [],
    children: [],
    fields: [],
    meta: {
      type: 'fieldset',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'FieldSet'
  },
  diagram: {
    name: '',
    type: 'diagram',
    parent: 'container',
    children: [],
    fields: [],
    meta: {
      type: 'diagram',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'FieldSet'
  },
  sheet: {
    name: '',
    type: 'sheet',
    parent: 'container',
    children: [],
    fields: [],
    meta: {
      type: 'sheet',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'FieldSet'
  },
  interface: {
    name: '',
    type: 'interface',
    parent: 'controller',
    children: [],
    fields: [],
    meta: {
      type: 'interface',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'FieldSet'
  },
  chart: {
    name: '',
    type: 'chart',
    parent: 'container',
    children: [],
    fields: [],
    meta: {
      type: 'chart',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'FieldSet'
  },
  member: {
    name: '',
    parent: [],
    children: [],
    roles: [],
    meta: {
      type: 'member',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'Member'
  },
  meta: {
    interface: {
      focus: null,
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'fieldset interface',
      __typename: 'JSONObject'
    },
    diagram: {
      view: '',
      focus: null,
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      zoom: {
        scale: 2.3,
        __typename: 'JSONObject'
      },
      center: { __typename: 'JSONObject' },
      options: [],
      filters: [],
      className: 'fieldset diagram',
      __typename: 'JSONObject'
    },
    sheet: {
      view: '',
      focus: null,
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'fieldset sheet',
      __typename: 'JSONObject'
    },
    chart: {
      view: '',
      focus: null,
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'fieldset chart',
      __typename: 'JSONObject'
    },
    fieldset: {
      notes: [],
      center: { __typename: 'JSONObject' },
      visible: true,
      depth: 0,
      view: 'Circle',
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      zoom: {
        scale: 3.75,
        __typename: 'JSONObject'
      },
      filters: [],
      className: 'fieldset',
      __typename: 'JSONObject'
    },
    field: {
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      alwaysDisplay: false,
      className: 'field',
      __typename: 'JSONObject'
    },
    account: {
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'account',
      __typename: 'JSONObject'
    },
    member: {
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'member',
      __typename: 'JSONObject'
    },
    role: {
      notes: [],
      attributes: {
        __typename: 'JSONObject'
      },
      options: [],
      filters: [],
      className: 'role',
      __typename: 'JSONObject'
    }
  },
  role: {
    name: '',
    type: 'role',
    parent: [],
    children: [],
    meta: {
      type: 'role',
      data: { __typename: 'JSONObject' },
      __typename: 'Meta'
    },
    __typename: 'Role'
  }
};


/**
 * The following constants are the ENUMS we use for graphql typeDefs.
 * We can use these variables in our type defs as well as other methods that will need a list of the valid values.
 * If you'd like to change any of these, use the `useDefaults()` Hook.
 */
export const MetaTypes = [
  'meta',
  'set',
  'fieldset',
  'field',
  'account',
  'member',
  'role',
  'custom'
];

export const FieldTypes = [
  'default',
  'text',
  'number',
  'currency',
  'decimal',
  'center',
  'coordinate',
  'location',
  'array',
  'list',
  'dictionary',
  'object',
  'search',
  'bool',
  'date',
  'time',
  'formula',
  'function',
  'callback',
  'output'
];

export const SetTypes = [
  'account',
  'member',
  'role',
  'fieldset',
  'filter',
  'interface',
  'controller',
  'custom'
];
