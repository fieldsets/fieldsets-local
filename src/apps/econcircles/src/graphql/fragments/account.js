export const account = `
  fragment account on Account @client(always: true) {
    id
    name
    type
    parent
    children
    members
  }
`;

export const member = `
  fragment member on Member @client(always: true) {
    id
    name
    parent
    type
    children
    roles
  }
`;

export const role = `
  fragment role on Role @client(always: true) {
    id
    name
    type
    parent
    children
  }
`;
