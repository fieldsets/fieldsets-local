export const field = `
  fragment field on Field @client(always: true) {
    id
    name
    description
    parent
    children
    value
    type
    callback
    owner
    order
    fieldsets
    meta {
      ...meta
    }
  }
`;
