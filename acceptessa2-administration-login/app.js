const express = require('express');
const app = express();

app.get('/', (req, res, next) => {
    res.json({ "hello": "world" });
});

module.exports = app;
