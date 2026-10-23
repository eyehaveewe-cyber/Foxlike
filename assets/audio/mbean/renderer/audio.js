// Salamander Grand Piano v3, Alexander Holm (CC BY 3.0).
// Mapping derived from sfzinstruments/SalamanderGrandPiano; see docs/samples.md.
const PIANO_BASE = "https://raw.githubusercontent.com/sfzinstruments/SalamanderGrandPiano/3382bf9496bba2486f5ab0de55a264d1dfc38404/Samples/";
const PIANO_VELOCITIES = [26,34,36,43,46,50,56,64,72,80,88,96,104,112,120,127];
const PIANO_ROOTS = Array.from({length:30}, (_,i) => 21+i*3);
function pianoSample(note, velocity) {
  const midi = noteToMidi(note);
  const root = PIANO_ROOTS.reduce((best,r) => Math.abs(r-midi)<Math.abs(best-midi)?r:best,21);
  const names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];
  const name = names[root%12]+(Math.floor(root/12)-1);
  const value = Math.max(1, Math.min(127, Math.round(velocity*127)));
  const layer = PIANO_VELOCITIES.findIndex(upper => value<=upper)+1;
  return {url:PIANO_BASE+encodeURIComponent(`${name}v${layer}.flac`),
    rate:2**((midi-root)/12), drum:false, instrument:"pianoSample", root, layer,
    release:root>=96?4:root>=90?3:.35};
}
const SAMPLE_BANKS = {
  fluteSample: [
    {
      root: "C5",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Flute/susNV/LDFlute_susNV_C4_v1_1.wav",
    },
    {
      root: "E5",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Flute/susNV/LDFlute_susNV_E4_v1_1.wav",
    },
    {
      root: "A5",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Flute/susNV/LDFlute_susNV_A4_v1_1.wav",
    },
  ],
  oboeSample: [
    {
      root: "D4",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Oboe/Sus/Oboe_Sus_D4_v1_Main.wav",
    },
    {
      root: "F4",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Oboe/Sus/Oboe_Sus_F4_v1_Main.wav",
    },
    {
      root: "A#4",
      url: "https://raw.githubusercontent.com/sgossner/VSCO-2-CE/440300901dfe9275fd84e0b7763af1f8443ae62e/Woodwinds/Oboe/Sus/Oboe_Sus_A%234_v1_Main.wav",
    },
  ],
};
const DRUM_SAMPLES = {
  kick: "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/kick/oh_kick_snon_vl3_rr1.flac",
  snare:
    "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/snare/oh_snare_center_vl18.flac",
  tom: "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/htom/oh_htom_center_vl8.flac",
  closedHat:
    "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/hh/oh_hh_closed_vl3_rr1.flac",
  openHat:
    "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/hh/oh_hh_open_vl2_rr1.flac",
  crash:
    "https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/oh/crash/oh_crash_crash_vl2_rr1.flac",
};

const NOTE_SEMITONES = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
const sampleBuffers = new Map(),
  sampleFailures = new Set(),
  samplePending = new Map(),
  activeVoices = new Set();
let audioCtx = null, voiceOutput = null, voiceOutputCleanup = null;
function trackVoice(source, gain, ctx, cleanup = () => {}) {
  const output = voiceOutput, outputCleanup=voiceOutputCleanup;
  if (ctx === audioCtx) activeVoices.add(source);
  source.onended = () => {
    activeVoices.delete(source);
    source.disconnect();
    gain.disconnect(); cleanup(); if(outputCleanup)outputCleanup();else if(output) output.disconnect();
  };
}
function ensureAudio() {
  if (!audioCtx || audioCtx.state === "closed")
    audioCtx = new (window.AudioContext || window.webkitAudioContext)({latencyHint:"interactive"});
  if (audioCtx.state === "suspended") audioCtx.resume();
  return audioCtx;
}
function noteToMidi(note) {
  const m = /^([A-G])(#?)(-?\d+)$/.exec(String(note));
  if (Number.isInteger(note)) return note;
  if (!m) return 60;
  return (Number(m[3]) + 1) * 12 + NOTE_SEMITONES[m[1]] + (m[2] ? 1 : 0);
}
function nearestSample(bank, note) {
  const target = noteToMidi(note);
  return bank.reduce(
    (best, s) =>
      Math.abs(noteToMidi(s.root) - target) <
      Math.abs(noteToMidi(best.root) - target)
        ? s
        : best,
    bank[0],
  );
}
async function loadSample(url) {
  if (sampleBuffers.has(url)) return sampleBuffers.get(url);
  if (sampleFailures.has(url)) throw new Error("sample unavailable");
  if (samplePending.has(url)) return samplePending.get(url);
  const pending = (async () => {
    try {
      const ctx = ensureAudio(),
        controller = new AbortController(),
        timeout = setTimeout(() => controller.abort(), 30000);
      let response;
      try {
        response = await fetch(url, {
          mode: "cors",
          signal: controller.signal,
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const buffer = await ctx.decodeAudioData(await response.arrayBuffer());
        sampleBuffers.set(url, buffer);
        return buffer;
      } finally {
        clearTimeout(timeout);
      }
    } catch (err) {
      sampleFailures.add(url);
      throw err;
    } finally {
      samplePending.delete(url);
    }
  })();
  samplePending.set(url, pending);
  return pending;
}
function sampleFor(instrument, note, velocity = 0.8, tick = 0) {
  if(instrument==="drumsSample"&&note==="rattle")return JazzSamples.select("shakerSample",note,velocity,tick);
  if(typeof PercussionSamples!=="undefined"){const spec=PercussionSamples.select(instrument,note,velocity,tick);if(spec)return spec;}
  if(typeof FluteSamples!=="undefined"){const flute=FluteSamples.select(instrument,noteToMidi(note));if(flute)return flute;}
  if (typeof ChoirSamples !== "undefined") { const choir = ChoirSamples.select(instrument, noteToMidi(note)); if (choir) return choir; }
  if (typeof JazzSamples !== 'undefined') {
    const jazz = JazzSamples.select(instrument, note, velocity, tick);
    if (jazz) return jazz;
  }
  if (instrument === "pianoSample") return pianoSample(note, velocity);
  if (instrument === "fluteSample" || instrument === "oboeSample") {
    const source = nearestSample(SAMPLE_BANKS[instrument], note);
    return {
      url: source.url,
      rate: Math.pow(2, (noteToMidi(note) - noteToMidi(source.root)) / 12),
      drum: false,
      instrument,
    };
  }
  if (instrument === "drumsSample") {
    const key = MusicModel.drumVoices.includes(note) ? note : "closedHat";
    return { url: DRUM_SAMPLES[key] || DRUM_SAMPLES.closedHat, rate: 1, drum: true };
  }
  return null;
}
function oscillatorNote(
  freq,
  dur,
  vol,
  type,
  ctx = ensureAudio(),
  now = ctx.currentTime,
) {
  const o = ctx.createOscillator(),
    g = ctx.createGain();
  const sustain = Math.max(1 / ctx.sampleRate, dur),
    peak = Math.max(0.001, vol);
  o.frequency.value = freq;
  o.type = ["sine", "triangle", "square", "sawtooth"].includes(type)
    ? type
    : "triangle";
  o.connect(g);
  g.connect(voiceOutput || ctx.destination);
  g.gain.setValueAtTime(0.001, now);
  g.gain.exponentialRampToValueAtTime(
    peak,
    now + Math.min(0.035, sustain * 0.18),
  );
  if (type === "pluck") {
    g.gain.exponentialRampToValueAtTime(
      0.001,
      now + Math.max(1 / ctx.sampleRate, sustain * 0.7),
    );
  } else {
    g.gain.setValueAtTime(
      peak,
      now +
        Math.max(
          Math.min(0.035, sustain * 0.18),
          sustain - Math.min(0.03, sustain * 0.35),
        ),
    );
    g.gain.exponentialRampToValueAtTime(0.001, now + sustain);
  }
  trackVoice(o, g, ctx);
  o.start(now);
  o.stop(now + sustain + 0.03);
}
function playLoadedSample(
  spec,
  note,
  dur,
  vol,
  ctx = ensureAudio(),
  now = ctx.currentTime,
) {
  const buffer = sampleBuffers.get(spec.url);
  if (!buffer) return false;
  const source = ctx.createBufferSource(),
    g = ctx.createGain();
  const peak = Math.max(0.001, vol * (spec.drum ? 1.8 : 2.2) * (spec.gain ?? 1));
  source.buffer = buffer;
  source.playbackRate.value = spec.rate;
  source.connect(g);
  g.connect(voiceOutput || ctx.destination);
  trackVoice(source, g, ctx);

  if (spec.drum) {
    g.gain.setValueAtTime(peak, now);
    source.start(now);
    return true;
  }

  // Preserve the recorded onset, except for an explicitly authored source offset.
  // Without authored loop points, let a recording end naturally instead of looping arbitrary audio.
  const offset = Math.min(spec.offsetSeconds ?? 0, buffer.duration);
  const looping = Number.isFinite(spec.loopStart) && Number.isFinite(spec.loopEnd) && spec.loopStart >= 0 && spec.loopEnd > spec.loopStart && spec.loopEnd <= buffer.duration;
  if (looping) { source.loop = true; source.loopStart = spec.loopStart; source.loopEnd = spec.loopEnd; }
  const natural = looping ? Infinity : (buffer.duration - offset) / spec.rate;
  const gate = Math.min(Math.max(1 / ctx.sampleRate, dur), natural);
  const release = Math.min(
    spec.release ?? (spec.instrument === "oboeSample" ? 0.12 : 0.18),
    Math.max(0, natural - gate),
  );
  const end = gate + release;
  if (spec.instrument === "pianoSample" || spec.struck) {
    // The recording supplies the hammer attack and decay; do not synthesize an ADSR attack.
    g.gain.setValueAtTime(peak, now);
  } else {
    g.gain.setValueAtTime(0, now);
    g.gain.linearRampToValueAtTime(peak, now + Math.min(spec.attack ?? 0.003, gate / 2));
  }
  g.gain.linearRampToValueAtTime(peak, now + gate);
  g.gain.linearRampToValueAtTime(0, now + end);
  source.start(now, offset);
  source.stop(now + end + 0.005);
  return true;
}

function playEvent(event, dur, vol, instrument, ctx, when) {
  if(instrument==="maracasSynth")return playMaracas(event,vol,ctx,when);
  if(instrument==="faustFlute")return FaustFlute.play(event,dur,vol,ctx,when);
  const pitch = event.drumVoice || event.pitch;
  let spec = sampleFor(instrument, pitch, event.velocity, event.startTick);
  if(instrument==="metalGuitarSample"&&event.articulation==="staccato"&&spec)spec={...spec,release:.04};
  const level = vol * (instrument === "pianoSample" ? event.velocity ** .73 : event.velocity);
  if (spec) {
    if (playLoadedSample(spec, pitch, dur, level, ctx, when)) return;
    throw Error("The selected instrument recording is unavailable. Use Retry samples; no substitute sound was played.");
  }
  const frequency = event.drumVoice
    ? {
        kick: 75,
        snare: 180,
        tom: 130,
        closedHat: 1800,
        openHat: 1500,
        crash: 2200, rattle:2600, ride:1700, rideBell:2400, crossStick:240,
      }[event.drumVoice]
    : 440 * Math.pow(2, (event.pitch - 69) / 12);
  oscillatorNote(frequency, dur, level, instrument, ctx, when);
}
function sampleUrls(tracks) {
  const urls = new Set();
  tracks.forEach((t) =>
    t.notes.forEach((n) => {
      const spec = sampleFor(
        t.instrument,
        n.drumVoice || n.pitch,
        n.velocity,
        n.startTick,
      );
      if (spec && n.velocity > 0) urls.add(spec.url);
    }),
  );
  return [...urls];
}
async function preloadSamples(tracks) {
  const urls = sampleUrls(audibleTracks(tracks)).filter(
    (u) => !sampleBuffers.has(u) && !sampleFailures.has(u),
  );
  if (urls.length) {
    status(`Loading ${urls.length} samples…`);
    // Limit concurrent large recordings; duplicates share loadSample's pending promise.
    let next = 0;
    await Promise.all(Array.from({length:Math.min(4,urls.length)}, async () => {
      while(next < urls.length) {
        const url = urls[next++];
        try { await loadSample(url); } catch { /* Fail below before playback or export. */ }
      }
    }));
  }
  const missing = sampleUrls(audibleTracks(tracks)).filter(url => !sampleBuffers.has(url));
  if (missing.length) throw Error("Selected instrument recordings could not load. Use Retry samples. Playback/export stopped without substituting a synth.");
}
function scheduleEvents(tracks, start, end, ctx, origin, bpm) {
  const secondsPerTick = 60 / bpm / MusicModel.PPQ;
  const events = [];
  const audible = audibleTracks(tracks);
  audible.forEach((t) =>
    t.notes.forEach((n) => {
      if (!MusicModel.overlaps(n, start, end) || n.velocity === 0) return;
      const onset = Math.max(n.startTick, start),
        gate = Math.min(MusicModel.end(n), end) - onset;
      // A drum is a one-shot. Seeking into its decay should not retrigger it.
      if (n.drumVoice && n.startTick < start) return;
      events.push({
        event: n,
        instrument: t.instrument,
        sound: t.sound, pan: t.pan ?? 0,
        volume: t.volume * 0.18,
        when: origin + (onset - start) * secondsPerTick,
        duration:
          gate * secondsPerTick * (n.articulation === "staccato" ? 0.5 : 1),
      });
    }),
  );
  return events.sort((a, b) => a.when - b.when);
}
function audibleTracks(tracks) {
  const solo = tracks.some(t => t.solo);
  return tracks.filter(t => !t.mute && (!solo || t.solo));
}
function dispatchEvent(item, ctx) {
  const pan=ctx.createStereoPanner(); pan.pan.value=item.pan??0;pan.connect(ctx.destination);
  const amp=item.instrument==="metalGuitarSample"?GuitarAmp.chain(ctx,pan,item.sound,item.event.articulation==="staccato"):null;voiceOutput=amp?amp.input:pan;voiceOutputCleanup=amp?()=>amp.disconnect():null;
  try {
    if (item.instrument === "faustFlute") return FaustFlute.play(item.event,item.duration,item.volume,ctx,item.when);
    if (item.instrument === "reedSynth") return playReed(item.event,item.duration,item.volume,ctx,item.when,item.sound);
    if (["pulseLead","chipBass","chipDrums","chipTom"].includes(item.instrument)) playChip(item.event,item.duration,item.volume,item.instrument,ctx,item.when,item.sound);
    else playEvent(item.event,item.duration,item.volume,item.instrument,ctx,item.when);
  } catch(error){if(amp)amp.disconnect();else pan.disconnect();throw error;} finally {voiceOutput=null;voiceOutputCleanup=null;}
}
function encodeWav(buffer) {
  const bytes = new ArrayBuffer(44 + buffer.length * 4),
    view = new DataView(bytes),
    rate = buffer.sampleRate;
  const str = (at, t) =>
    [...t].forEach((c, i) => view.setUint8(at + i, c.charCodeAt(0)));
  str(0, "RIFF");
  view.setUint32(4, bytes.byteLength - 8, true);
  str(8, "WAVE");
  str(12, "fmt ");
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 2, true);
  view.setUint32(24, rate, true);
  view.setUint32(28, rate * 4, true);
  view.setUint16(32, 4, true);
  view.setUint16(34, 16, true);
  str(36, "data");
  view.setUint32(40, buffer.length * 4, true);
  const channels = [buffer.getChannelData(0), buffer.getChannelData(1)];
  let peak = 1;
  for (const channel of channels)
    for (const value of channel) peak = Math.max(peak, Math.abs(value));
  for (let i = 0; i < buffer.length; i++)
    for (let c = 0; c < 2; c++)
      view.setInt16(
        44 + (i * 2 + c) * 2,
        Math.round((channels[c][i] / peak) * 32767),
        true,
      );
  return new Blob([bytes], { type: "audio/wav" });
}
async function renderAudio(tracks, bpm, start, end, tail = null) {
  tail ??= audibleTracks(tracks).some(t => t.instrument === "pianoSample") ? 4 : 2;
  ensureAudio();
  await preloadSamples(tracks);
  const ctx = new OfflineAudioContext(
    2,
    Math.ceil((((end - start) * 60) / bpm / MusicModel.PPQ + tail) * 44100),
    44100,
  );
  scheduleEvents(tracks, start, end, ctx, 0, bpm).forEach((item) =>
    dispatchEvent(item, ctx),
  );
  return encodeWav(await ctx.startRendering());
}


// A releaseable audition bus: authored loops keep sounding until release.
async function startKeyboardHold(track,pitch,velocity) {
 const ctx=ensureAudio();if(ctx.state!=="running")await ctx.resume();
 if(track.instrument==='faustFlute')return FaustFlute.hold(ctx,pitch,velocity,track.volume*.18,track.pan);
 const spec=sampleFor(track.instrument,pitch,velocity,0);if(spec&&!sampleBuffers.has(spec.url))await loadSample(spec.url);
 const bus=ctx.createGain(),pan=ctx.createStereoPanner();pan.pan.value=track.pan??0;bus.connect(pan);pan.connect(ctx.destination);
 const before=new Set(activeVoices);voiceOutput=bus;
 try {const event=MusicModel.note(0,MusicModel.PPQ,pitch,velocity);if(track.instrument==='reedSynth')playReed(event,60,track.volume*.18,ctx,ctx.currentTime,track.sound);else if(['pulseLead','chipBass','chipDrums','chipTom'].includes(track.instrument))playChip(event,60,track.volume*.18,track.instrument,ctx,ctx.currentTime,track.sound);else playEvent(event,3600,track.volume*.18,track.instrument,ctx,ctx.currentTime);}finally{voiceOutput=null;}
 const voices=[...activeVoices].filter(s=>!before.has(s));let released=false;
 return {stop(){if(released)return;released=true;const t=ctx.currentTime,release=spec?.release??.15;bus.gain.cancelAndHoldAtTime(t);bus.gain.linearRampToValueAtTime(0,t+release);voices.forEach(s=>{try{s.stop(t+release+.01)}catch{}});setTimeout(()=>{bus.disconnect();pan.disconnect();},(release+.03)*1000);}};
}

async function previewTrackNote(track, event) {
  try {
    const ctx = ensureAudio(); if(ctx.state!=="running")await ctx.resume();
    const spec=sampleFor(track.instrument,event.drumVoice||event.pitch,event.velocity,event.startTick);
    if(spec&&!sampleBuffers.has(spec.url))await loadSample(spec.url);
    dispatchEvent({event, duration:.2, volume:track.volume*.18, instrument:track.instrument, sound:track.sound, pan:track.pan, when:ctx.currentTime}, ctx);
  } catch (error) { status(error.message); }
}
