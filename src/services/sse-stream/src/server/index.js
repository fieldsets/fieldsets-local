const api = require('./api');
const CONSTANTS = require('./constants');

api.listen(CONSTANTS.API_PORT, () => {
    console.log(`SSE Tutorial API is active. Port: ${CONSTANTS.API_PORT}`);
});