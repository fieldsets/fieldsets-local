const express = require('express');
const cors = require('cors')
const http = require('http')
const { ApolloServer } = require('apollo-server-express');
const { ApolloServerPluginDrainHttpServer } = require('apollo-server-core');
const mongoose = require('mongoose');
require('dotenv').config()

const typeDefs = require('./graphql/typeDefs');
const resolvers = require('./graphql/resolvers');

const MONGODB = process.env.MONGO_DB_URI;
console.log(MONGODB)

async function startApolloServer() {
    const app = express();
    app.use(cors());
    const httpServer = http.createServer(app);
    const server = new ApolloServer({
        typeDefs,
        resolvers,
        plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
    });

    await server.start();

    const port = 5000
    // Mount Apollo middleware here.
    server.applyMiddleware({ app });
    await new Promise(resolve => httpServer.listen({ port: port }, resolve));
    console.log(`🚀 Server ready at http://localhost:${port}/graphql`);
    return { server, app };
}


mongoose.connect(MONGODB, {useNewUrlParser: true})
    .then(() => {
        console.log("MongoDB Connected");
        return startApolloServer()
    })