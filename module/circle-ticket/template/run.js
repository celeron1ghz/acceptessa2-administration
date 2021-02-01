async function getPuppeteer() {
    const puppeteer_params = {
        headless: true,
        args: ['--no-sandbox', '--disable-gpu', '--single-process'],
        executablePath: '../node_modules/puppeteer/.local-chromium/linux-818858/chrome-linux/chrome',
    };

    const puppeteer = require('puppeteer-core');
    const browser = await puppeteer.launch(puppeteer_params);
    return browser;
}

const fileUrl = require('file-url');

(async function () {
    const browser = await getPuppeteer();
    const page = await browser.newPage();

    page.setViewport({ width: 320, height: 600 });

    await page.goto(fileUrl('index.html') + "?circle_name=bbbbbb&count=3", { waitUntil: ['domcontentloaded', 'networkidle0'] });

    await page.screenshot({ path: 'moge.png' });

    await browser.close();
})()