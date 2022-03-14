const userResolvers = require('./users')

module.exports = {
  Query: {
    ...userResolvers.Query
  },
  Mutation: {
    ...userResolvers.Mutation
  }
}