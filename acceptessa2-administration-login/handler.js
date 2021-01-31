'use strict';

const aws = require('aws-sdk');
const ddb = new aws.DynamoDB.DocumentClient();
const cf = new aws.CloudFront();

const ejs = require('ejs');

const q = require('query-string');
const v = require('email-validator');
const b = require('js-base64');
const r = require('rand-token');
const fs = require('fs');
const crypto = require('crypto');

const index_page = fs.readFileSync('./template/index.ejs', 'utf8');
const privateKey = fs.readFileSync('private_key.pem');

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
                expire_at: Math.ceil(expire_at),
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

function make_cookie(keyGroupId) {
    // `foo=bar; Secure; HttpOnly; Expires=${date.toUTCString()}`,
    const expire = Math.ceil(Date.now() / 1000) + 86400;
    const policy = {
        "Statement": [{
            "Resource": "https://administration.familiar-life.info/*",
            "Condition": { "DateLessThan": { "AWS:EpochTime": expire } }
        }]
    };

    const serialized = JSON.stringify(policy);
    const sign = crypto.createSign("RSA-SHA1");
    sign.update(serialized);

    const signed = sign.sign(privateKey, 'base64');
    const cfpolicy = Buffer.from(serialized).toString('base64').replace(/\+/g, "-").replace(/\=/g, "_").replace(/\//g, "~");
    const cfsignature = signed.replace(/\+/g, "-").replace(/\=/g, "_").replace(/\//g, "~")

    return [
        `CloudFront-Key-Pair-Id=${keyGroupId}`,
        `CloudFront-Policy=${cfpolicy}`,
        `CloudFront-Signature=${cfsignature}`,
    ];
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

    const keyGroups = await cf.listKeyGroups().promise();
    const keyGroup = keyGroups.KeyGroupList.Items.filter(data => data.KeyGroup.KeyGroupConfig.Name === 'acceptessa2-administration');
    const keyGroupId = keyGroup[0].KeyGroup.KeyGroupConfig.Items[0];

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'text/html' },
        cookies: make_cookie(keyGroupId),
        body: "OK",
    };
};