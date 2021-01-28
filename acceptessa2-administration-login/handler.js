'use strict';

const aws = require('aws-sdk');
const ddb = new aws.DynamoDB.DocumentClient();

const ejs = require('ejs');
const fs = require('fs');

const q = require('query-string');
const v = require('email-validator');
const b = require('js-base64');
const r = require('rand-token');

const index_page = fs.readFileSync('./template/index.ejs', 'utf8');

module.exports.check = async (event) => {
    const req = event.requestContext;
    const query = event.body ? q.parse(b.Base64.decode(event.body)) : [];
    let valid = false;

    if (req.http.method === "POST" && v.validate(query.mail)) {
        valid = true;
        const token = r.generate(64);
        const expire_at = (new Date().getTime() / 1000) + 60 * 60 * 1; // 1 hour
        console.log(token);

        await ddb.put({
            TableName: 'acceptessa2-login-token',
            Item: {
                token: token,
                mail: query.mail,
                expire_at: expire_at,
            }
        }).promise();
    }

    const content = ejs.render(index_page, { test: valid ? "OK" : 'NOT' });

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'text/html' },
        body: content,
    };
};

module.exports.login = async (event) => {
    const t = event.queryStringParameters
        ? event.queryStringParameters.t
        : null;

    if (!t) {
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'text/html' },
            body: "NO",
        };
    }

    const ret = await ddb.get({ TableName: 'acceptessa2-login-token', Key: { token: t } }).promise();
    
    if (!ret || !ret.Item) {
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'text/html' },
            body: "NO_REC",
        };
    }
    
    const mail = ret.Item.mail;
    console.log("login as " + mail);
    
    await ddb.delete({ TableName: 'acceptessa2-login-token', Key: { token: t } }).promise();

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'text/html' },
        body: "OK",
    };
};