const redis = require('ioredis');
const CONSTANTS = require('./constants');

const redis_client = new redis(CONSTANTS.REDIS_PORT, CONSTANTS.REDIS_HOST);

redis_client.on("connect", () => {
    console.log(`==> Successfully connected to Redis DB on address: ${CONSTANTS.REDIS_HOST}:${CONSTANTS.REDIS_PORT}`);
});

redis_client.on("error", (error) => {
    console.error(`Error while attempting to connect to Redis DB: ${error}`);
});

module.exports = {

    getEmployees: async () => {
        let employees = [];
        try {
            employees = await redis_client.lrange('employees', 0, -1);
        } catch (error) {
            console.error(`getEmployees() | Could not obtain employees from Redis. Error: ${error}`);
        }
        return employees;
    },

    addEmployee: async (employee) => {
        try {
            await redis_client.rpush('employees', employee);
        } catch (error) {
            throw new Error(`unable to push employee. Error ${error}`);
        }
    }
}