let CLIENT_POOL = [];

module.exports = {

    add: (client) => {
        CLIENT_POOL.push(client);
    },

    remove: (id) => {
        CLIENT_POOL = CLIENT_POOL.filter(client => client.id !== id);
    },

    getAll: () => {
        return CLIENT_POOL;
    }
}