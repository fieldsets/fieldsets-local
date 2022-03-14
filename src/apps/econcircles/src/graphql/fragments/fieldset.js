export const fieldset = `
  fragment fieldset on FieldSet @client(always: true) {
    id
    name
    type
    parent
    children
    fields
    meta {
      ...meta
    }
  }
`;
