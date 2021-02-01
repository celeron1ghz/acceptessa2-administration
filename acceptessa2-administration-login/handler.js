'use strict';

const aws = require('aws-sdk');
const ddb = new aws.DynamoDB.DocumentClient();
const cf = new aws.CloudFront();

const q = require('query-string');
const v = require('email-validator');
const b = require('js-base64');
const r = require('rand-token');
const fs = require('fs');
const ejs = require('ejs');
const crypto = require('crypto');

const indexPage = fs.readFileSync('./template/index.ejs', 'utf8');
const privateKey = fs.readFileSync('private_key.pem');
const TOKEN_TABLE = 'acceptessa2-login-token';

module.exports.login = async (event) => {
    const query = event.body ? q.parse(b.Base64.decode(event.body)) : [];
    const t = event.queryStringParameters ? event.queryStringParameters.t : null;
    const mail = query ? query.mail : null;

    if (event.requestContext.http.method === "POST" && v.validate(mail)) {
        // verifying mail
        const token = r.generate(64);
        const expire_at = (new Date().getTime() / 1000) + 60 * 60 * 1; // 1 hour
        console.log(token);

        await ddb.put({
            TableName: TOKEN_TABLE,
            Item: {
                token: token,
                mail: mail,
                expire_at: Math.ceil(expire_at),
            }
        }).promise();

        const content = ejs.render(indexPage, { test: "OK" });
        return response(200, content);
    } else if (t) {
        // come from mail's link
        const ret = await ddb.get({ TableName: TOKEN_TABLE, Key: { token: t } }).promise();

        if (!ret || !ret.Item) {
            return response(200, "NO_REC");
        }

        const mail = ret.Item.mail;
        console.log("login as " + mail);

        await ddb.delete({ TableName: TOKEN_TABLE, Key: { token: t } }).promise();

        const keyGroups = await cf.listKeyGroups().promise();
        const keyGroup = keyGroups.KeyGroupList.Items.filter(data => data.KeyGroup.KeyGroupConfig.Name === 'acceptessa2-administration');
        const keyGroupId = keyGroup[0].KeyGroup.KeyGroupConfig.Items[0];

        return {
            statusCode: 200,
            headers: { 'Content-Type': 'text/html' },
            cookies: make_cookie(keyGroupId),
            body: "OK. <a href='./member/'>move!</a>",
        };

    } else {
        // normal access
        const content = ejs.render(indexPage, { test: 'NOT' });
        return response(200, content);
    }
};

function response(code, body) {
    return {
        statusCode: code,
        headers: { 'Content-Type': 'text/html' },
        body: body,
    };
}

function make_cookie(keyGroupId) {
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
        `CloudFront-Key-Pair-Id=${keyGroupId}; Secure; HttpOnly;`,
        `CloudFront-Policy=${cfpolicy}; Secure; HttpOnly;`,
        `CloudFront-Signature=${cfsignature}; Secure; HttpOnly;`,
    ];
}
