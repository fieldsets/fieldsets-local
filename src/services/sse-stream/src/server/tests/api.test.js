const request = require('supertest');
const api = require('../api');
const http = require('http');

describe('API Endpoints Tests', () => {

    let server;

    beforeAll((done) => {
        server = http.createServer(api);
        server.listen(done);
    });

    afterAll((done) => {
        server.close(done);
    });

    it('checks-in an employee and stores it in Redis', async (done) => {
        const res = await request(api)
        .post('/api/employee/check-in')
        .set('Content-type', 'application/json')
        .send({ employee: 'Daniel Wind' })
        expect(res.statusCode).toEqual(201);
        expect(res.body).toHaveProperty('message');
        expect(res.body).toEqual({message: 'success'});
        done();
    });

/*
    it('subscribe a client and stores it in Redis', async (done) => {
        const res = await request(api)
        .get('/api/subscribe')
        expect(res.statusCode).toEqual(200);
        expect(res.header['Content-Type']).toEqual("text/event-stream");
        expect(res.header['Cache-Control']).toEqual("no-cache");
        expect(res.header['Connection']).toEqual("keep-alive");
        expect(res.write).to.have.been.called.once;
        done();
    });
*/  
});