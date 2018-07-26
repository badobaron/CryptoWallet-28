const routes = require('next-routes')();

routes
    .add('transactions/new')
    .add('transactions/recipient')
    .add('transactions/recipient/:address');

module.exports = routes;    