#!/usr/bin/env node
/** Real Chromium/WebGL smoke: normal input, read-only opt-in game telemetry.
 * Install Playwright (`npm install --no-save playwright`) or provide NODE_PATH.
 * Run after `python tools/package_release.py --platform web`.
 * Optional: CHROMIUM_EXECUTABLE=/path/to/chromium node tests/web_smoke.cjs
 */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const { chromium } = require('playwright');

const root = path.resolve(__dirname, '..');
const build = path.resolve(process.env.FOXLIKE_WEB_BUILD || path.join(root, 'build/web'));
const output = path.resolve(process.env.FOXLIKE_WEB_QA || path.join(root, 'build/web-smoke'));
const mime = { '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.png': 'image/png', '.svg': 'image/svg+xml' };
const errors = [];
const checks = [];
function addError(message) { if (!errors.includes(message)) errors.push(message); }
let browser;
let page;
let server;

function check(name, condition, details) {
  assert.ok(condition, `${name}: ${JSON.stringify(details)}`);
  checks.push({ name, details });
  console.log(`PASS ${name}`);
}
async function state() {
  return page.evaluate(() => window.__foxlikeQA);
}
async function waitMode(expected) {
  await page.waitForFunction(mode => window.__foxlikeQA?.mode === mode, expected, { timeout: 45000 });
  return state();
}
async function picture(name) {
  await page.screenshot({ path: path.join(output, `${name}.png`) });
}
function serve(request, response) {
  let relative;
  try { relative = decodeURIComponent(new URL(request.url, 'http://localhost').pathname); }
  catch { response.writeHead(400); response.end(); return; }
  const file = path.resolve(build, '.' + (relative === '/' ? '/index.html' : relative));
  if (!file.startsWith(build + path.sep)) { response.writeHead(403); response.end(); return; }
  response.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream');
  fs.createReadStream(file).on('error', () => { response.statusCode = 404; response.end(); }).pipe(response);
}

(async () => {
  assert.ok(fs.existsSync(path.join(build, 'index.html')), 'Export Web first: build/web/index.html is missing');
  fs.mkdirSync(output, { recursive: true });
  // Keep the server and browser in one process, including isolated CI namespaces.
  server = http.createServer(serve);
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_EXECUTABLE || undefined,
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--js-flags=--max-old-space-size=512', '--renderer-process-limit=1', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
  });
  page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  page.on('pageerror', error => addError(error.message));
  page.on('console', message => {
    const text = message.text();
    if (message.type() === 'error' || /SCRIPT ERROR:|Parse Error:/.test(text)) addError(text);
  });
  await page.goto(`http://127.0.0.1:${server.address().port}/?qa=1`, { waitUntil: 'domcontentloaded' });
  const menu = await waitMode('MENU');
  check('WebGL game starts at flight deck', menu.mode === 'MENU', menu);
  await picture('web-menu');
  await page.keyboard.press('Enter');
  const briefing = await waitMode('BRIEFING');
  check('Keyboard launches mission briefing', briefing.mode === 'BRIEFING', briefing);
  await picture('web-briefing');
  await page.keyboard.press('Enter');
  await waitMode('LAUNCH');
  const flight = await waitMode('FLIGHT');
  check('Animated launch reaches playable flight', flight.mode === 'FLIGHT', flight);

  const xBefore = Number(flight.player_x);
  await page.keyboard.down('d');
  await page.waitForFunction(x => Number(window.__foxlikeQA?.player_x) > x + 2.0, xBefore, { timeout: 15000 });
  await page.keyboard.up('d');
  const moved = await state();
  check('Keyboard steers ship right', Number(moved.player_x) > xBefore + 0.5, { xBefore, xAfter: moved.player_x });
  await page.keyboard.down('a');
  await page.waitForFunction(x => Number(window.__foxlikeQA?.player_x) < x - 0.6, Number(moved.player_x), { timeout: 15000 });
  await page.keyboard.up('a');
  const beforeFire = await state();
  await page.keyboard.down('Space');
  await page.waitForFunction(shots => Number(window.__foxlikeQA?.shots_fired) >= shots + 4, Number(beforeFire.shots_fired), { timeout: 15000 });
  await page.keyboard.up('Space');
  const fired = await state();
  check('Holding fire creates laser shots', Number(fired.shots_fired) > Number(beforeFire.shots_fired), { before: beforeFire.shots_fired, after: fired.shots_fired });
  await page.keyboard.press('e');
  await page.waitForTimeout(180);
  await picture('web-flight');

  await page.keyboard.press('Escape');
  await page.waitForFunction(() => window.__foxlikeQA?.paused === true);
  await page.waitForTimeout(150);
  const paused = await state();
  await page.waitForTimeout(700);
  const stillPaused = await state();
  check('Pause freezes mission clock', stillPaused.paused && Math.abs(Number(stillPaused.flight_time) - Number(paused.flight_time)) < 0.06, { before: paused.flight_time, after: stillPaused.flight_time });
  await picture('web-paused');
  await page.keyboard.press('Escape');
  await page.waitForFunction(() => window.__foxlikeQA?.paused === false);
  await page.waitForFunction(time => Number(window.__foxlikeQA?.flight_time) > time + 0.1, Number(stillPaused.flight_time), { timeout: 15000 });
  const resumed = await state();
  check('Resume advances flight again', Number(resumed.flight_time) > Number(stillPaused.flight_time), resumed);
  check('No JavaScript or engine console errors', errors.length === 0, errors);
  fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify({ passed: true, browser: browser.version(), checks, errors }, null, 2) + '\n');
  const previousFailure = path.join(output, 'web-failure.png');
  if (fs.existsSync(previousFailure)) fs.unlinkSync(previousFailure);
  console.log(`WEB_SMOKE_OK ${checks.length} checks; captures in ${output}`);
})().catch(async error => {
  if (page && !page.isClosed()) {
    try { await picture('web-failure'); } catch { /* Browser may have terminated. */ }
  }
  fs.mkdirSync(output, { recursive: true });
  fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify({ passed: false, checks, errors, failure: error.message }, null, 2) + '\n');
  console.error(error);
  process.exitCode = 1;
}).finally(async () => {
  if (browser) await browser.close().catch(() => {});
  if (server) await new Promise(resolve => server.close(resolve));
});
