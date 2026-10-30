#!/usr/bin/env node
// Validate actual editable scores and, with --audio, decode shipped OGG streams.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const crypto = require('node:crypto');
const {execFileSync} = require('node:child_process');
const ROOT = path.join(__dirname, 'campaign');
const context = vm.createContext({console});
vm.runInContext(fs.readFileSync(path.join(__dirname, 'renderer/model.js'), 'utf8') +
  '\nthis.model = MusicModel;', context);
const M = context.model;
const digest = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const SYNTHS = new Set(['pulseLead', 'chipBass', 'chipDrums', 'chipTom']);
const OPERATIONS = new Map([
  ['viridia_last_ferry', {world:'viridia', index:12}],
  ['aurora_courier', {world:'aurora', index:13}],
  ['terminus_falling_yard', {world:'terminus', index:14}],
  ['tempest_stormbreak', {world:'tempest', index:15}],
]);

function validateScores() {
  const manifest = JSON.parse(fs.readFileSync(path.join(ROOT, 'manifest.json'), 'utf8'));
  assert.equal(manifest.version, 1);
  assert.equal(manifest.cues.length, 16);
  const ids = new Set(), destinations = new Set(), melodies = new Set(), eventIds = new Set();
  for (const cue of manifest.cues) {
    assert.equal(cue.file, cue.id + '.json');
    assert.equal(typeof cue.boss, 'boolean');
    assert(!ids.has(cue.id)); ids.add(cue.id);
    let destination;
    if (OPERATIONS.has(cue.id)) {
      const operation = OPERATIONS.get(cue.id);
      assert.equal(cue.operation_id, cue.id);
      assert.equal(cue.world, operation.world);
      assert.equal(cue.playback_index, operation.index);
      assert.equal(cue.stage, undefined, cue.id + ' uses an operation destination');
      assert.equal(cue.boss, false);
      destination = cue.playback_index;
    } else {
      assert.match(cue.id, /^(viridia|aurora|terminus|cinder|anchorage|tempest)-(flight|boss)$/);
      assert(Number.isInteger(cue.stage) && cue.stage >= 0 && cue.stage < 6);
      destination = cue.stage * 2 + Number(cue.boss);
    }
    assert(!destinations.has(destination)); destinations.add(destination);
    const source = JSON.parse(fs.readFileSync(path.join(ROOT, cue.file), 'utf8'));
    const p = M.validate(source);
    assert.equal(p.bpm, cue.bpm);
    assert.equal(p.bars, cue.bars);
    assert.equal(p.arrangement.endTick, p.bars * M.BAR);
    assert(Math.abs(cue.seconds - p.bars * 4 * 60 / p.bpm) < 0.01);
    assert(p.tracks.length >= 3);
    assert(p.tracks.some(t => t.role === 'lead' && t.notes.length > 30));
    const notes = p.tracks.flatMap(t => t.notes);
    assert.equal(new Set(notes.map(n => n.id)).size, notes.length, cue.id + ' unique event IDs');
    for (const note of notes) {
      assert(!eventIds.has(note.id), cue.id + ' event ID unique across all projects');
      eventIds.add(note.id);
    }
    for (const track of p.tracks) {
      assert(SYNTHS.has(track.instrument), cue.id + ' must not download sample assets');
      assert(track.notes.length > 0);
      for (const note of track.notes) {
        assert(note.startTick >= 0 && M.end(note) <= p.arrangement.endTick, cue.id + ' bounded notes');
        // Match playChip's real fixed drum/tom tails and pitched envelopes.
        const release = track.sound.release;
        const tails = {kick: 0.22 + release, tom: 0.30 + release, snare: 0.16 + release,
          closedHat: 0.035 + release * 0.2, openHat: 0.22 + release,
          rattle: 0.10 + release * 0.5, crash: 0.45 + release,
          ride: 0.30 + release, rideBell: 0.40 + release, crossStick: 0.04 + release * 0.2};
        const secondsPerTick = 60 / p.bpm / M.PPQ;
        const duration = note.drumVoice ? tails[note.drumVoice] : track.instrument === 'chipTom' ?
          0.30 + release : note.durationTicks * secondsPerTick * (note.articulation === 'staccato' ? 0.5 : 1) + release;
        assert(note.startTick * secondsPerTick + duration + 0.005 <= cue.seconds + 0.00001,
          cue.id + ' sounding tail clears loop end');
      }
    }
    // Compare authored rhythm and relative contour, ignoring absolute key,
    // tempo, velocity, IDs and release trimming. A transposed/time-scaled copy
    // does not become a distinct campaign composition.
    const signature = JSON.stringify(p.tracks.filter(t => t.role === 'lead').map(t =>
      t.notes.map(n => [n.startTick, n.pitch - t.notes[0].pitch])));
    assert(!melodies.has(signature), cue.id + ' distinct authored line'); melodies.add(signature);
  }
  assert.equal(destinations.size, 16);
  for (let index=0; index<16; index++) assert(destinations.has(index), 'complete playback slot ' + index);
  return manifest;
}

function inspectAudio(cue, file) {
  const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-select_streams', 'a:0',
    '-show_entries', 'stream=codec_name,sample_rate,channels,duration', '-of', 'json', file], {encoding: 'utf8'}));
  const stream = probe.streams[0];
  assert.equal(stream.codec_name, 'vorbis');
  assert.equal(Number(stream.sample_rate), 44100);
  assert.equal(stream.channels, 2);
  assert(Math.abs(Number(stream.duration) - cue.seconds) < 0.01, cue.id + ' duration');
  const pcm = execFileSync('ffmpeg', ['-v', 'error', '-i', file, '-f', 'f32le', '-acodec', 'pcm_f32le', '-'],
    {maxBuffer: 128 * 1024 * 1024});
  const frames = pcm.length / 8;
  let peak = 0, sum = 0, silentWindows = 0, maxSilentWindows = 0;
  const block = 4410;
  for (let start = 0; start < frames; start += block) {
    let energy = 0;
    const end = Math.min(start + block, frames);
    for (let i = start; i < end; i++) for (let ch = 0; ch < 2; ch++) {
      const value = pcm.readFloatLE(i * 8 + ch * 4);
      assert(Number.isFinite(value), cue.id + ' finite PCM');
      peak = Math.max(peak, Math.abs(value)); energy += value * value;
    }
    sum += energy;
    silentWindows = Math.sqrt(energy / (end - start) / 2) < 0.0001 ? silentWindows + 1 : 0;
    maxSilentWindows = Math.max(maxSilentWindows, silentWindows);
  }
  const rms = Math.sqrt(sum / frames / 2);
  const seamDelta = Math.max(...[0, 1].map(ch => Math.abs(
    pcm.readFloatLE(ch * 4) - pcm.readFloatLE((frames - 1) * 8 + ch * 4))));
  assert(peak > 0.01 && peak < 0.98, cue.id + ' encoded peak/headroom');
  assert(rms > 0.002, cue.id + ' audible signal');
  // Sparse phrases deliberately breathe for a beat. Reject long empty padding,
  // and retain the measured gap so musical rests can be reviewed in context.
  assert(maxSilentWindows < 15, cue.id + ' no long empty padding');
  // A periodic waveform need not have identical adjacent samples. A large jump
  // is a seam defect; small differences still require perceptual review.
  assert(seamDelta < 0.12, cue.id + ' loop-boundary discontinuity ' + seamDelta);
  return {seconds: Number(stream.duration), frames, peak, rms, rmsDb: 20 * Math.log10(rms),
    seamDelta, maxSilenceSeconds: maxSilentWindows * 0.1, bytes: fs.statSync(file).size};
}

if (require.main === module) {
  const manifest = validateScores();
  const checkAudio = process.argv.includes('--audio');
  const checkHashes = checkAudio || process.argv.includes('--hashes');
  if (checkHashes) {
    const report = JSON.parse(fs.readFileSync(path.join(ROOT, 'render-report.json'), 'utf8'));
    assert.equal(report.cues.length, 16, 'complete audio render inventory');
    assert.equal(new Set(report.cues.map(r=>r.id)).size, 16, 'unique audio render records');
    for (const [file, sha] of Object.entries(report.source))
      assert.equal(digest(path.join(__dirname, 'renderer', file)), sha, 'pinned renderer hash');
    for (const cue of manifest.cues) {
      const record = report.cues.find(r => r.id === cue.id);
      assert(record, cue.id + ' render record');
      const audio = path.join(ROOT, cue.id + '.ogg');
      assert.equal(digest(path.join(ROOT, cue.file)), record.scoreSha256, cue.id + ' score hash');
      assert.equal(digest(audio), record.audioSha256, cue.id + ' audio hash');
      if (checkAudio) console.log(JSON.stringify({id: cue.id, ...inspectAudio(cue, audio)}));
    }
  }
  console.log('CAMPAIGN_SCORE: ' + manifest.cues.length + ' valid, distinct MBean1 projects' +
    (checkAudio ? '; ' + manifest.cues.length + ' decoded OGG loops verified' : checkHashes ? '; renderer, score and audio hashes verified' : ''));
}
module.exports = {validateScores, inspectAudio, digest};
