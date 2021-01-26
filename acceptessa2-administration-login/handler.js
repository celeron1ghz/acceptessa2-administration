'use strict';

const handler = require('serverless-express/handler')
const app = require('./app')
exports.hello = handler(app)