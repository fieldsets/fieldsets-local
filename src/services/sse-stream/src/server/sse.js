const uuid = require('uuid');
const clientManager = require('./client-manager');

module.exports = {

    broadcast: async (redis) => {
        try {
            const employees = await redis.getEmployees();
            const clients = clientManager.getAll();
            if(clients) {
                clients.forEach(client => {
                    //format response text as SSE protocol mandates: data: ****
                    client.response.write(`\ndata: ${JSON.stringify(employees)}\n\n`);
                });
            }
        } catch (error) {
            console.error(`broadcast() | could not broadcast employee check-in to connected clients. Error: ${error}`);
        }
    },

    addPeer: async (redis, req, res) => {
        try {
            //minimum headers for keeping the client connection open
            const headers = {
                'Content-Type': 'text/event-stream',
                'Connection': 'keep-alive',
                'Cache-Control': 'no-cache'
            };

            res.writeHead(200, headers);
            const employees = await redis.getEmployees();
            res.write(`\ndata: ${JSON.stringify(employees)}\n\n`);

            const id = uuid.v1();
            clientManager.add({id: id, response: res});

            req.on('close', async () => {
                console.warn(`Client ID: ${id} - Connection closed`);
                await clientManager.remove(id);
            });

        } catch (error) {
            console.error(`addPeer() | could not add the peer connection. Error: ${error}`);
        }
    }
}