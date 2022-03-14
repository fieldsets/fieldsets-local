const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const redis = require('./redis');
const sse = require('./sse');

const api = express();
api.use(cors({origin: '*'}));
api.use(bodyParser.json());
api.use(bodyParser.urlencoded({extended: false}));


//routes
api.post('/api/employee/check-in', async (req, res) => {
    try{
        const {employee} = req.body;
        await redis.addEmployee(employee);
        await sse.broadcast(redis);
        return res.status(201).send({message: 'success'});
    }catch(error){
        console.error(`check-in endpoint error. Error: ${error}`);
        return res.status(500).send({message: error});
    }
});

api.get('/api/subscribe', async (req, res) => { 
    try {
        await sse.addPeer(redis, req, res);
    } catch (error) {
        console.error(`SSE subscribe endpoint error. Error: ${error}`);
        return res.status(500).send({message: error});
    }
});

module.exports = api;