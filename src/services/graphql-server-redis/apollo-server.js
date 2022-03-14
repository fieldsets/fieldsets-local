import { ApolloServer } from 'apollo-server-express';
import Redis  from 'ioredis';
import express from 'express';
import { resolvers, typeDefs } from './lib/fieldsets/graphql'; 

const PORT = process.env.GRAPHQL_PORT;
const redis = new Redis({
  connectTimeout: 20000,
  lazyConnect: true
});

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: { redis }
});
const app = express();
server.applyMiddleware({ app });

app.listen({ port: PORT }, () => {
  console.log(`🚀 Server ready at http://localhost:${PORT}${server.graphqlPath}`);
});
