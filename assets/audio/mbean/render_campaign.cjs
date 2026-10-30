#!/usr/bin/env node
// Render authored campaign scores through the unchanged, pinned MBean1 engine.
// NODE_PATH must resolve Playwright. CHROMIUM_PATH may select an installed browser.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const crypto = require('node:crypto');
const {execFileSync} = require('node:child_process');
const {chromium} = require('playwright');
const ROOT = __dirname;
const OUTPUT = path.join(ROOT, 'campaign');
const {validateScores, inspectAudio, digest} = require('./validate_campaign.cjs');

async function main() {
  const manifest = validateScores();
  const browser = await chromium.launch({
    executablePath: process.env.CHROMIUM_PATH || undefined,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--single-process'],
  });
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'foxlike-campaign-'));
  const captures = [];
  try {
    const page = await browser.newPage();
    page.on('console', message => console.log('MBean1: ' + message.text()));
    page.setDefaultTimeout(180000);
    await page.goto('about:blank');
    for (const file of ['model.js', 'chip-audio.js', 'audio.js'])
      await page.addScriptTag({path: path.join(ROOT, 'renderer', file)});
    const waveCacheMaxDelta = await page.evaluate(async () => {
      // Each pulse width has the same Fourier coefficients on every note.
      // Reuse its immutable PeriodicWave per context rather than rebuilding
      // hundreds of identical wavetable banks. The synthesis itself is unchanged.
      const createWave = pulseWave;
      const cache = new WeakMap();
      const cachedWave = (ctx, width) => {
        if (!cache.has(ctx)) cache.set(ctx, new Map());
        const waves = cache.get(ctx);
        if (!waves.has(width)) waves.set(width, createWave(ctx, width));
        return waves.get(width);
      };
      const renderCheck = async factory => {
        pulseWave = factory;
        const ctx = new OfflineAudioContext(2, 44100, 44100);
        for (const [pitch, when] of [[72, 0], [76, 0.3]])
          dispatchEvent({event: MusicModel.note(0, 120, pitch, 0.8), duration: 0.2,
            volume: 0.08, instrument: 'pulseLead', sound: MusicModel.soundDefaults('pulseLead'),
            pan: 0, when}, ctx);
        return (await ctx.startRendering()).getChannelData(0);
      };
      const original = await renderCheck(createWave);
      const cached = await renderCheck(cachedWave);
      let delta = 0;
      for (let i = 0; i < original.length; i++) delta = Math.max(delta, Math.abs(original[i] - cached[i]));
      if (delta > 1e-7) throw Error('Pulse-wave cache changed audio: ' + delta);
      pulseWave = cachedWave;
      return delta;
    });
    console.log('Pulse-wave cache equivalence, maximum PCM delta: ' + waveCacheMaxDelta);
    for (const cue of manifest.cues) {
      console.log('Rendering ' + cue.id + ': ' + cue.title);
      const scoreText = fs.readFileSync(path.join(OUTPUT, cue.file), 'utf8');
      const score = JSON.parse(scoreText);
      const scoreSha256 = crypto.createHash('sha256').update(scoreText).digest('hex');
      const seed = crypto.createHash('sha256').update(cue.id).digest().readUInt32LE();
      const capture = await page.evaluate(async ({score, seed}) => {
        // Noise percussion uses a fixed PRNG for reproducible offline captures.
        let state = seed;
        Math.random = () => {
          state = (state + 0x6D2B79F5) | 0;
          let n = Math.imul(state ^ (state >>> 15), 1 | state);
          n ^= n + Math.imul(n ^ (n >>> 7), 61 | n);
          return ((n ^ (n >>> 14)) >>> 0) / 4294967296;
        };
        const p = MusicModel.validate(score);
        const ticks = p.arrangement.endTick;
        const seconds = ticks / MusicModel.PPQ * 60 / p.bpm;
        const frames = Math.round(seconds * 44100);
        // These authored scores clear every gate and release before the seam.
        // A complete single pass therefore retains all intended sounding tails.
        const ctx = new OfflineAudioContext(2, frames, 44100);
        const scheduled = scheduleEvents(p.tracks, 0, ticks, ctx, 0, p.bpm);
        scheduled.forEach(item => dispatchEvent(item, ctx));
        console.log('Scheduled ' + scheduled.length + ' events; rendering ' + seconds.toFixed(3) + ' seconds');
        const rendered = await ctx.startRendering();
        let peak = 0, sum = 0, finite = true;
        for (let ch = 0; ch < 2; ch++) {
          const source = rendered.getChannelData(ch);
          for (const value of source) {
            finite &&= Number.isFinite(value);
            peak = Math.max(peak, Math.abs(value));
            sum += value * value;
          }
        }
        if (!finite || peak > 0.98 || peak < 0.0001)
          throw Error('Invalid/silent/overloaded raw render: peak=' + peak);
        // encodeWav receives peaks below one, so its overload guard is inactive.
        const bytes = new Uint8Array(await encodeWav(rendered).arrayBuffer());
        let binary = '';
        for (let i = 0; i < bytes.length; i += 8192)
          binary += String.fromCharCode(...bytes.subarray(i, i + 8192));
        return {wav: btoa(binary), rawPeak: peak, rawRms: Math.sqrt(sum / frames / 2), frames};
      }, {score, seed});
      const wavPath = path.join(temp, cue.id + '.wav');
      fs.writeFileSync(wavPath, Buffer.from(capture.wav, 'base64'));
      delete capture.wav;
      captures.push({...capture, cue, wavPath, scoreSha256});
    }
    // One gain for the entire score preserves authored relative dynamics.
    const commonGain = Math.min(6, 0.72 / Math.max(...captures.map(c => c.rawPeak)));
    const records = [];
    for (const c of captures) {
      if (digest(path.join(OUTPUT, c.cue.file)) !== c.scoreSha256)
        throw Error(c.cue.id + ': score changed during rendering; run again after authoring finishes');
      const output = path.join(OUTPUT, c.cue.id + '.ogg');
      execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-i', c.wavPath,
        '-af', 'volume=' + commonGain, '-c:a', 'libvorbis', '-q:a', '5',
        '-metadata', 'title=' + c.cue.title, '-metadata', 'artist=Foxlike original MBean1 score', output]);
      const audio = inspectAudio(c.cue, output);
      records.push({id: c.cue.id, scoreSha256: c.scoreSha256,
        audioSha256: digest(output), seed: crypto.createHash('sha256').update(c.cue.id).digest().readUInt32LE(),
        rawPeak: c.rawPeak, rawRms: c.rawRms, ...audio});
      console.log(JSON.stringify({id: c.cue.id, ...audio}));
    }
    const report = {version: 1, renderer: 'MBean1 Web Audio synthesis, full single-pass loops; authored gates and releases clear the seam',
      sampleRate: 44100, channels: 2, commonGain, waveCacheMaxDelta,
      source: Object.fromEntries(['model.js', 'chip-audio.js', 'audio.js'].map(file =>
        [file, digest(path.join(ROOT, 'renderer', file))])), cues: records};
    fs.writeFileSync(path.join(OUTPUT, 'render-report.json'), JSON.stringify(report, null, 2) + '\n');
  } finally {
    await browser.close();
    fs.rmSync(temp, {recursive: true, force: true});
  }
}
main().catch(error => { console.error(error); process.exitCode = 1; });
