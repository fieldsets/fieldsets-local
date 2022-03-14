import gql from 'graphql-tag';
import * as defaults from './defaults';
const metatypes = defaults.MetaTypes.join(" \n");
const settypes = defaults.SetTypes.join(" \n");
const fieldtypes = defaults.FieldTypes.join(" \n");

export const typeDefs = gql`
  type Member implements Set {
    id: ID!
    name: String
    type: SetType
    parent: ID
    children: [ID]
    meta: Meta
    roles: [ID]
  }

  type Account implements Set {
    id: ID!
    name: String!
    type: SetType
    parent: ID
    children: [ID]
    members: [ID]
    meta: Meta
  }

  type Role implements Set {
    id: ID!
    name: String
    type: SetType
    parent: ID
    children: [ID]
    meta: Meta
  }

  type FieldSet implements Set {
    id: ID!
    name: String
    type: SetType
    parent: ID
    children: [ID]
    fields: [ID]
    meta: Meta
  }

  type Field {
    id: ID!
    name: String
    description: String
    parent: [ID]
    children: [ID]
    fieldsets: [ID]
    value: JSON
    type: FieldType
    callback: JSONObject
    order: Int
    owner: ID
    meta: Meta
  }

  type Zoom implements Coordinate {
    x: Int
    y: Int
    Scale: Int
  }

  type Center implements Coordinate {
    x: Int
    y: Int
  }

  type Meta {
    id: ID!
    type: MetaType
    data: JSONObject
  }

  interface Coordinate {
    x: Int
    y: Int
  }

  type Focus {
    id: ID!
    name: String
    focusID: ID
    focusGroup: ID
    parent: ID
    center: JSONObject
    container: JSONObject
    depth: Int
    expanded: Boolean
    zoom: JSONObject
  }

  input ContainerData {
    id: ID!
    name: String
    type: String
    parent: ID
    children: [ID]
    fields: [ID]
  }

  input Fields {
    fields: [ID]
  }

  input FieldData {
    id: ID!
    name: String
    description: String
    parent: [ID]
    children: [ID]
    fieldsets: [ID]
    value: JSON
    type: FieldType
    callback: JSONObject
    order: Int
    owner: ID
    meta: MetaData
  }

  input MetaData {
    id: ID
    type: MetaType
    data: JSONObject
  }

  type Mutation {
    updateFocus(id: ID!): Focus
    updateContainer(data: ContainerData): [FieldSet]
    updateFields(data: FieldData): [Field]
  }

  type Query {
    fetchFocus: Focus
    fetchContainer: FieldSet
    fetchContainerData: [FieldSet]
    fetchFields(data: Fields): [Field]
  }

  enum FieldType {
    ${fieldtypes}
  }

  enum SetType {
    ${settypes}
  }

  enum MetaType {
    ${metatypes}
  }

  scalar JSON
  scalar JSONObject

  interface Set {
    id: ID!
    type: SetType
    parent: ID
    children: [ID]
    meta: Meta
  }
`;
