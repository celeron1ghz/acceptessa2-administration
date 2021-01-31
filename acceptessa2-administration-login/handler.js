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

        const url = `https://${event.requestContext.domainName}/login?t=${token}`;
        console.log(token);
        console.log(url);

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

function response(code, body) {
    return {
        statusCode: code,
        headers: { 'Content-Type': 'text/html' },
        body: body,
    };
}

module.exports.login = async (event) => {
    const t = event.queryStringParameters
        ? event.queryStringParameters.t
        : null;

    if (!t) {
        return response(200, "NO");
    }

    const ret = await ddb.get({ TableName: 'acceptessa2-login-token', Key: { token: t } }).promise();

    if (!ret || !ret.Item) {
        return response(200, "NO_REC");
    }

    const mail = ret.Item.mail;
    console.log("login as " + mail);

    await ddb.delete({ TableName: 'acceptessa2-login-token', Key: { token: t } }).promise();

    const date = new Date();
    date.setTime(date.getTime() + 86400 * 1000);

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'text/html' },
        cookies: [
            `moge=fuga; Secure; Expires=${date.toUTCString()}`,
            `foo=bar; Secure; HttpOnly; Expires=${date.toUTCString()}`,
        ],
        body: "OK",
    };
};