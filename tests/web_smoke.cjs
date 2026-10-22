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
// Software-rendered CI must produce at least 65 frames for the 3.2-second
// launch (game delta is capped at 0.05). Keep real input and bounded waits,
// while reducing the pixel workload to one quarter on shared runners.
const viewport = { width: 640, height: 360 };
const modeTimeout = 180000;
const actionTimeout = 45000;
const startedAt = Date.now();
function addError(message) { if (!errors.includes(message)) errors.push(message); }
let browser;
let page;
let server;
let currentStep = 'start browser';
let lastTelemetry = null;

function check(name, condition, details) {
  assert.ok(condition, `${name}: ${JSON.stringify(details)}`);
  checks.push({ name, elapsed_ms: Date.now() - startedAt, details });
  console.log(`PASS ${name}`);
}
async function state() {
  lastTelemetry = await page.evaluate(() => window.__foxlikeQA);
  return lastTelemetry;
}
async function waitMode(expected) {
  currentStep = `wait for ${expected}`;
  await page.waitForFunction(mode => window.__foxlikeQA?.mode === mode, expected, { timeout: modeTimeout, polling: 250 });
  return state();
}
async function waitAction(label, predicate, argument) {
  currentStep = label;
  await page.waitForFunction(predicate, argument, { timeout: actionTimeout, polling: 250 });
}
function evidence() {
  return { browser: browser?.version(), viewport, mode_timeout_ms: modeTimeout,
    action_timeout_ms: actionTimeout, elapsed_ms: Date.now() - startedAt, last_telemetry: lastTelemetry };
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
  page = await browser.newPage({ viewport, deviceScaleFactor: 1 });
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
  await waitAction('steer right', x => Number(window.__foxlikeQA?.player_x) > x + 2.0, xBefore);
  await page.keyboard.up('d');
  const moved = await state();
  check('Keyboard steers ship right', Number(moved.player_x) > xBefore + 0.5, { xBefore, xAfter: moved.player_x });
  await page.keyboard.down('a');
  await waitAction('steer left', x => Number(window.__foxlikeQA?.player_x) < x - 0.6, Number(moved.player_x));
  await page.keyboard.up('a');
  const beforeFire = await state();
  await page.keyboard.down('Space');
  await waitAction('fire four shots', shots => Number(window.__foxlikeQA?.shots_fired) >= shots + 4, Number(beforeFire.shots_fired));
  await page.keyboard.up('Space');
  const fired = await state();
  check('Holding fire creates laser shots', Number(fired.shots_fired) > Number(beforeFire.shots_fired), { before: beforeFire.shots_fired, after: fired.shots_fired });
  await page.keyboard.down('Shift');
  await page.keyboard.down('ArrowDown');
  await waitAction('boost-down long loop', () => window.__foxlikeQA?.maneuver === 'LONG LOOP' && window.__foxlikeQA?.player_z < -12);
  await page.keyboard.up('ArrowDown');
  check('Boost plus down performs forward long loop', (await state()).player_z < -12, await state());
  await picture('web-long-loop');
  await waitAction('long loop settles', () => window.__foxlikeQA?.maneuver === '' && Math.abs(window.__foxlikeQA?.player_z) < 0.15);
  await page.keyboard.up('Shift');
  check('Long loop returns to flight depth', Math.abs((await state()).player_z) < 0.15, await state());
  await page.keyboard.press('e');
  await page.waitForTimeout(180);
  await picture('web-flight');

  await page.keyboard.press('Escape');
  await waitAction('pause game', () => window.__foxlikeQA?.paused === true);
  await page.waitForTimeout(150);
  const paused = await state();
  await page.waitForTimeout(700);
  const stillPaused = await state();
  check('Pause freezes mission clock', stillPaused.paused && Math.abs(Number(stillPaused.flight_time) - Number(paused.flight_time)) < 0.06, { before: paused.flight_time, after: stillPaused.flight_time });
  await picture('web-paused');
  await page.keyboard.press('Escape');
  await waitAction('resume game', () => window.__foxlikeQA?.paused === false);
  await waitAction('advance resumed mission', time => Number(window.__foxlikeQA?.flight_time) > time + 0.1, Number(stillPaused.flight_time));
  const resumed = await state();
  check('Resume advances flight again', Number(resumed.flight_time) > Number(stillPaused.flight_time), resumed);
  check('No JavaScript or engine console errors', errors.length === 0, errors);
  fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify({ passed: true, ...evidence(), checks, errors }, null, 2) + '\n');
  const previousFailure = path.join(output, 'web-failure.png');
  if (fs.existsSync(previousFailure)) fs.unlinkSync(previousFailure);
  console.log(`WEB_SMOKE_OK ${checks.length} checks; captures in ${output}`);
})().catch(async error => {
  let diagnostics = null;
  if (page && !page.isClosed()) {
    try {
      diagnostics = await Promise.race([
        page.evaluate(() => ({ telemetry: window.__foxlikeQA ?? null,
          ready_state: document.readyState,
          canvas: [...document.querySelectorAll('canvas')].map(canvas => ({ width: canvas.width, height: canvas.height })) })),
        new Promise(resolve => setTimeout(() => resolve({ unavailable: 'Renderer did not answer within 5 seconds' }), 5000)),
      ]);
      if (diagnostics?.telemetry) lastTelemetry = diagnostics.telemetry;
      await page.screenshot({ path: path.join(output, 'web-failure.png'), timeout: 10000 });
    } catch { /* Preserve the original failure if the renderer has terminated. */ }
  }
  fs.mkdirSync(output, { recursive: true });
  const result = { passed: false, ...evidence(), failed_step: currentStep, diagnostics, checks, errors, failure: error.message };
  fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(result, null, 2) + '\n');
  console.error('WEB_SMOKE_FAILURE', JSON.stringify({ step: currentStep, last_telemetry: lastTelemetry, diagnostics }));
  console.error(error);
  process.exitCode = 1;
}).finally(async () => {
  if (browser) await browser.close().catch(() => {});
  if (server) await new Promise(resolve => server.close(resolve));
});
