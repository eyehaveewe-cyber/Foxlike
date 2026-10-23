// Authoritative event model. All time values are integer ticks (480 per quarter note).
const MusicModel = (() => {
  const PPQ = 480,
    STEP = 120,
    BAR = 1920,
    VERSION = 4,
    DEFAULT_BARS = 64,
    MAX_BARS = 1024;
  // Add every new sound here with a stable ID, label and sound type.
  const soundTypes = {realistic: "Realistic · recorded instruments", chiptune: "Chiptune", synth: "Synthesized", legacy: "Legacy basic synth · MIDI-like (manual only)"};
  const instrumentCatalog = [
    {id:"metalGuitarSample",label:"Metal guitar · recorded electric + modeled amp",soundType:"synth"},
    {id:"concertBassDrumSample",label:"Concert bass drum set · VCSL CC0",soundType:"realistic"},
    {id:"lowTomSample",label:"Low tenor tom set · VCSL CC0",soundType:"realistic"},
    {id:"timpaniSetSample",label:"Timpani set · FreePats CC0",soundType:"realistic"},
    {id:"taikoSample",label:"Taiko set · SCC / Floe · CC BY-SA 4.0",soundType:"realistic"},
    {id:"sitarSample",label:"Sitar · Raikar CC0",soundType:"realistic"},
    {id:"saxelloSample",label:"Saxello · straight tone · VCSL CC0",soundType:"realistic"},
    {id:"shakerSample",label:"Small shaker · VCSL CC0",soundType:"realistic"},
    {id:"maracasSynth",label:"Maracas · local percussion model",soundType:"synth"},
    {id:"nylonGuitarSample",label:"Nylon guitar · FreePats CC0",soundType:"realistic"},
    {id:"archtopGuitarSample",label:"Acoustic archtop guitar · Shinyguitar CC0",soundType:"realistic"},
    {id:"electricGuitarSample",label:"Clean electric guitar · Shinyguitar CC0",soundType:"realistic"},
    {id:"violinSample",label:"Solo violin · VSCO CC0",soundType:"realistic"},
    {id:"violinPizzSample",label:"Pizzicato violin · VSCO CC0",soundType:"realistic"},
    {id:"harpSample",label:"Concert harp · VCSL CC0",soundType:"realistic"},
    {id:"faustFlute",label:"Breath flute · Faust physical model",soundType:"synth"},
    {id:"fluteVpoSample",label:"Sustained flute · VSCO / VPO CC0",soundType:"realistic"},
    {id:"choirMixedSample",label:"Mixed choir · Sonatina / VPO",soundType:"realistic"},
    {id:"choirMaleSample",label:"Male choir · Sonatina / VPO",soundType:"realistic"},
    {id:"choirFemaleSample",label:"Female choir · Sonatina / VPO",soundType:"realistic"},
    {"id": "sine", "label": "Soft sine", "soundType": "legacy", "aiAllowed": false},
    {"id": "triangle", "label": "Basic triangle", "soundType": "legacy", "aiAllowed": false},
    {"id": "square", "label": "Basic square", "soundType": "legacy", "aiAllowed": false},
    {"id": "sawtooth", "label": "Basic saw", "soundType": "legacy", "aiAllowed": false},
    {"id": "pluck", "label": "Basic pluck", "soundType": "legacy", "aiAllowed": false},
    {"id": "pianoSample", "label": "Grand piano · Salamander CC BY 3.0", "soundType": "realistic"},
    {"id": "fluteSample", "label": "Sampled flute — VSCO CC0", "soundType": "realistic"},
    {"id": "oboeSample", "label": "Sampled oboe — VSCO CC0", "soundType": "realistic"},
    {"id": "drumsSample", "label": "Acoustic drums — Virtuosity CC0", "soundType": "realistic"},
    {"id": "altoSaxSample", "label": "Alto sax · Weresax", "soundType": "realistic"},
    {"id": "tenorSaxSample", "label": "Tenor sax · VCSL", "soundType": "realistic"},
    {"id": "uprightBassSample", "label": "Upright bass · quiet Sneakybass", "soundType": "realistic"},
    {"id": "meatBassSample", "label": "Upright bass · Meatbass pizzicato", "soundType": "realistic"},
    {"id": "wurlitzerSample", "label": "Wurlitzer EP200", "soundType": "realistic"},
    {"id": "pianetSample", "label": "Hohner Pianet T", "soundType": "realistic"},
    {"id": "cp80Sample", "label": "Yamaha CP80 electric grand", "soundType": "realistic"},
    {"id": "marimbaSample", "label": "Marimba · wooden mallets", "soundType": "realistic"},
    {"id": "vibraphoneSample", "label": "Vibraphone · soft mallets", "soundType": "realistic"},
    {"id": "brushDrumsSample", "label": "Brushed drums · Swirly CC0", "soundType": "realistic"},
    {"id": "pulseLead", "label": "Pulse lead · local synth", "soundType": "chiptune"},
    {"id": "chipBass", "label": "Chip bass · local synth", "soundType": "chiptune"},
    {"id": "chipDrums", "label": "Noise and chip drums · local synth", "soundType": "chiptune"},
    {"id": "chipTom", "label": "Pitched tom · local synth", "soundType": "chiptune"},
    {"id": "reedSynth", "label": "Reed · local synth", "soundType": "synth"},
  ];
  const instruments = instrumentCatalog.map(sound => sound.id);
  const drumVoices = ["kick", "snare", "tom", "closedHat", "openHat", "crash", "rattle", "ride", "rideBell", "crossStick"];
  const legacyDrums = [
    "kick",
    "kick",
    "snare",
    "snare",
    "tom",
    "tom",
    "closedHat",
    "closedHat",
    "openHat",
    "openHat",
    "crash",
    "crash",
  ];
  const isDrum = instrument => ["drumsSample", "brushDrumsSample", "chipDrums", "shakerSample", "maracasSynth", "concertBassDrumSample", "lowTomSample", "timpaniSetSample", "taikoSample"].includes(instrument);
  const isReed = instrument => ["reedSynth","oboeSample","altoSaxSample","tenorSaxSample","saxelloSample"].includes(instrument);
  const isGuitar = instrument => ["nylonGuitarSample","archtopGuitarSample","electricGuitarSample","metalGuitarSample"].includes(instrument);
  const playerFor = instrument => isDrum(instrument)?"drums":isReed(instrument)?"reed":isGuitar(instrument)?"guitar":"piano";
  const playerAllows = (player,instrument) => instruments.includes(instrument) && playerFor(instrument)===player;
  const soundDefaults = instrument => ({attack: .008, decay: instrument === "chipBass" ? .12 : .09, sustain: instrument === "chipBass" ? .65 : .55, release: .10, pulseWidth: .25, vibratoDepth: instrument === "pulseLead" ? .12 : 0, vibratoRate: 5, cutoff: instrument === "chipBass" ? 1800 : 18000, bassWave: "triangle",guitarDrive:16,guitarTone:4500});
  const soundPresets = {
    reed: {name:"Simple warm reed",instrument:"reedSynth",settings:{attack:.025,decay:.08,sustain:.8,release:.12,vibratoDepth:.12,vibratoRate:5,cutoff:5200}},
    tom: {name:"Pitched round tom",instrument:"chipTom",settings:{release:.15,cutoff:3000}},
    sharp: {name: "Sharp hook", instrument: "pulseLead", settings: {pulseWidth:.25, attack:.005, decay:.08, sustain:.55, release:.06, vibratoDepth:.10}},
    hollow: {name: "Hollow pulse", instrument: "pulseLead", settings: {pulseWidth:.5, attack:.012, decay:.16, sustain:.45, release:.16, vibratoDepth:.18}},
    narrow: {name: "Narrow sparkle", instrument: "pulseLead", settings: {pulseWidth:.125, attack:.004, decay:.10, sustain:.30, release:.08, vibratoDepth:.08}},
    warm: {name: "Warm triangle bass", instrument: "chipBass", settings: {bassWave:"triangle", cutoff:1400, attack:.008, decay:.15, sustain:.70, release:.08}},
    punch: {name: "Punchy pulse bass", instrument: "chipBass", settings: {bassWave:"pulse", pulseWidth:.35, cutoff:1100, attack:.004, decay:.10, sustain:.45, release:.06}},
    crisp: {name: "Crisp chip kit", instrument: "chipDrums", settings: {release:.08}},
    loose: {name: "Roomier chip kit", instrument: "chipDrums", settings: {release:.20}}
  };
  function soundSettings(value, instrument) {
    const d = soundDefaults(instrument), v = value ?? {};
    if (typeof v !== "object" || Array.isArray(v) || v === null) throw Error("Invalid sound settings.");
    const limits = {attack:[.001,2],decay:[.001,2],sustain:[0,1],release:[.005,3],pulseWidth:[.05,.95],vibratoDepth:[0,.5],vibratoRate:[.1,10],cutoff:[80,20000],guitarDrive:[1,40],guitarTone:[1500,9000]};
    for (const k of Object.keys(v)) if (!(k in d)) throw Error("Unknown sound setting.");
    for (const [k,[a,b]] of Object.entries(limits)) d[k] = number(v[k] ?? d[k],a,b,k);
    d.bassWave = v.bassWave ?? d.bassWave;
    if (!["triangle","pulse"].includes(d.bassWave)) throw Error("Invalid bass waveform.");
    return d;
  }
  let serial = 0;
  const id = () =>
    globalThis.crypto?.randomUUID?.() || `mbean-${Date.now()}-${++serial}`;
  const clone = (x) => JSON.parse(JSON.stringify(x));
  const note = (startTick, durationTicks, pitch, velocity = 0.8) => ({
    id: id(),
    startTick,
    durationTicks,
    pitch,
    velocity,
    articulation: "normal",
    pitchBend: [],
  });
  const track = (name, instrument = "pianoSample", volume = 0.6) => ({
    id: id(),
    name,
    instrument,
    volume,
    role: "auto",
    pan: 0, mute: false, solo: false, sound: soundDefaults(instrument), preset: "custom",
    viewTop: name === "Bass" ? 59 : 83,
    notes: [],
  });
  const defaultProject = () => ({
    version: VERSION,
    bpm: 110,
    bars: DEFAULT_BARS,
    currentPage: 0,
    currentTrack: 0,
    selection: [0, BAR],
    currentTick: 0,
    playhead: 0,
    entryMode: "step",
    playRange: null,
    arrangement: {clips:[],sections:[],endTick:null,zoom:48,editBars:4,rollStart:0,selectedTrackIds:[],selectedClipIds:[],multiEdit:false},
    suggestions: [],
    brief: briefSettings({}),
    composition: compositionSettings({}, MAX_BARS * BAR),
    tracks: [
      track("Lead"),
      track("Harmony", "pianoSample", 0.45),
      track("Bass", "uprightBassSample", 0.38),
      track("Drums", "drumsSample", 0.42),
    ],
  });
  const end = (n) => n.startTick + n.durationTicks;
  const overlaps = (n, a, b) => n.startTick < b && end(n) > a;
  const sort = (notes) =>
    notes.sort(
      (a, b) => a.startTick - b.startTick || (a.pitch ?? 0) - (b.pitch ?? 0),
    );
  function integer(v, min, max, label) {
    if (!Number.isInteger(v) || v < min || v > max)
      throw Error(`Invalid ${label}.`);
    return v;
  }
  function number(v, min, max, label) {
    if (typeof v !== "number" || !Number.isFinite(v) || v < min || v > max)
      throw Error(`Invalid ${label}.`);
    return v;
  }
  function region(value, total, fallback, allowNull = false) {
    if (value === undefined) return fallback;
    if (value === null && allowNull) return null;
    if (!Array.isArray(value) || value.length !== 2)
      throw Error("Invalid time range.");
    const a = integer(value[0], 0, total - 1, "range start"),
      b = integer(value[1], 1, total, "range end");
    if (b <= a) throw Error("Range end must follow its start.");
    return [a, b];
  }
  function migrateLegacy(p) {
    if (!Array.isArray(p.tracks) || !p.tracks.length || p.tracks.length > 16)
      throw Error("Project must contain 1–16 tracks.");
    const maxRows = Math.max(
      16,
      ...p.tracks.map((t) => (Array.isArray(t.notes) ? t.notes.length : 0)),
    );
    const bars = p.bars ?? Math.max(32, Math.ceil(maxRows / 16 / 4) * 4);
    integer(bars, 4, MAX_BARS, "bar count");
    const steps = bars * 16;
    const tracks = p.tracks.map((t, i) => {
      if (!Array.isArray(t.notes) || t.notes.length > steps)
        throw Error("Invalid legacy note grid.");
      for (const row of t.notes)
        if (
          !Array.isArray(row) ||
          row.length !== 12 ||
          row.some((v) => typeof v !== "boolean" && v !== 0 && v !== 1)
        )
          throw Error("Invalid legacy note row.");
      const out = {
        ...track(
          t.name || `Track ${i + 1}`,
          t.instrument || "triangle",
          t.volume ?? 0.5,
        ),
        id: t.id || id(),
        role: t.role || "auto",
      };
      for (let pi = 0; pi < 12; pi++)
        for (let s = 0; s < t.notes.length; s++) {
          if (!t.notes[s][pi]) continue;
          let stop = s + 1;
          if (!isDrum(out.instrument))
            while (stop < t.notes.length && t.notes[stop][pi]) stop++;
          const event = note(s * STEP, (stop - s) * STEP, 71 - pi);
          if (isDrum(out.instrument)) {
            delete event.pitch;
            event.drumVoice = legacyDrums[11 - pi];
          }
          out.notes.push(event);
          s = stop - 1;
        }
      sort(out.notes);
      return out;
    });
    const convertRange = (r) => [r[0] * STEP, (r[1] + 1) * STEP];
    return {
      ...defaultProject(),
      ...p,
      version: VERSION,
      bars,
      tracks,
      currentTick: (p.currentStep || 0) * STEP,
      playhead: (p.playhead || 0) * STEP,
      selection: p.selection ? convertRange(p.selection) : [0, BAR],
      playRange: p.playRange ? convertRange(p.playRange) : null,
      composition: {
        root: 0,
        scale: "major",
        ...p.composition,
        length: (p.composition?.length || 16) * STEP,
      },
    };
  }
  function validate(input) {
    if (!input || typeof input !== "object" || Array.isArray(input))
      throw Error("Expected a project object.");
    if (
      input.version !== undefined &&
      (!Number.isInteger(input.version) ||
        input.version < 1 ||
        input.version > VERSION)
    )
      throw Error("Unsupported project version.");
    const p = input.version === VERSION ? clone(input) : migrateLegacy(input);
    integer(p.bars, 4, MAX_BARS, "bar count");
    number(p.bpm, 45, 220, "tempo");
    const total = p.bars * BAR;
    if (!Array.isArray(p.tracks) || !p.tracks.length || p.tracks.length > 16)
      throw Error("Project must contain 1–16 tracks.");
    const ids = new Set();
    let eventCount = 0;
    const unique = (value) => {
      if (
        typeof value !== "string" ||
        !value.length ||
        value.length > 100 ||
        ids.has(value)
      )
        throw Error("Invalid or duplicate ID.");
      ids.add(value);
      return value;
    };
    const tracks = p.tracks.map((t, i) => {
      if (!instruments.includes(t.instrument))
        throw Error("Unknown instrument.");
      if (!Array.isArray(t.notes) || t.notes.length > 50000)
        throw Error("Invalid note list.");
      if (!["auto", "lead", "harmony", "bass"].includes(t.role ?? "auto"))
        throw Error("Unknown track role.");
      for (const k of ["mute", "solo"]) if (t[k] !== undefined && typeof t[k] !== "boolean") throw Error("Invalid track " + k);
      const preset=t.preset ?? "custom";
      if (preset !== "custom" && soundPresets[preset]?.instrument !== t.instrument) throw Error("Invalid sound preset.");
      const notes = t.notes.map((n) => {
        if (++eventCount > 100000)
          throw Error("Project contains too many notes.");
        const out = {
          id: unique(n.id),
          startTick: integer(n.startTick, 0, total - 1, "note start"),
          durationTicks: integer(n.durationTicks, 1, total, "note duration"),
          velocity: number(n.velocity, 0, 1, "velocity"),
          articulation: n.articulation ?? "normal",
          pitchBend: [],
        };
        if (end(out) > total) throw Error("Note extends beyond the project.");
        if (!["normal", "staccato"].includes(out.articulation))
          throw Error("Unsupported articulation.");
        if (
          n.pitchBend !== undefined &&
          (!Array.isArray(n.pitchBend) || n.pitchBend.length)
        )
          throw Error("Pitch bends are not supported by this version yet.");
        if ((n.drumVoice !== undefined) !== (isDrum(t.instrument)))
          throw Error(
            "Drum events require a drum track; pitched notes require a pitched track.",
          );
        if (n.drumVoice !== undefined) {
          if (!drumVoices.includes(n.drumVoice))
            throw Error("Unknown drum voice.");
          out.drumVoice = ["shakerSample","maracasSynth"].includes(t.instrument) ? "rattle" : n.drumVoice;
        } else out.pitch = integer(n.pitch, 0, 127, "MIDI pitch");
        if (n.singing !== undefined) {
          const a=n.singing;
          if (!a || typeof a!=="object" || n.drumVoice!==undefined) throw Error("Invalid singing metadata.");
          out.singing={measuredMidi:number(a.measuredMidi,0,127,"measured singing pitch"),cents:number(a.cents,-100,100,"singing cents"),
            clarity:number(a.clarity,0,1,"singing clarity"),originalPitch:integer(a.originalPitch,0,127,"original singing pitch"),
            originalStartTick:integer(a.originalStartTick,0,MAX_BARS*BAR-1,"original singing start"),
            originalDurationTicks:integer(a.originalDurationTicks,1,MAX_BARS*BAR,"original singing duration"),timingQuantized:a.timingQuantized===true};
        }
        return out;
      });
      return {
        id: unique(t.id),
        name: String(t.name || `Track ${i + 1}`).slice(0, 24),
        instrument: t.instrument,
        volume: number(t.volume, 0, 1, "track volume"),
        role: t.role ?? "auto",
        pan: number(t.pan ?? 0,-1,1,"pan"), mute: t.mute ?? false, solo: t.solo ?? false, sound: soundSettings(t.sound,t.instrument), preset,
        viewTop: integer(
          t.viewTop ?? (t.role === "bass" ? 59 : 83),
          23,
          127,
          "view pitch",
        ),
        notes: sort(notes),
      };
    });
    const composition = compositionSettings(p.composition ?? {}, total);
    const arrangement = arrangementSettings(p.arrangement ?? {}, tracks, total, unique, p.currentPage ?? 0);
    const suggestions = suggestionSettings(p.suggestions ?? []);
    return {
      version: VERSION,
      bpm: p.bpm,
      bars: p.bars,
      tracks,
      currentTrack: integer(
        p.currentTrack ?? 0,
        0,
        tracks.length - 1,
        "current track",
      ),
      currentPage: integer(
        p.currentPage ?? 0,
        0,
        Math.ceil(p.bars / 4) - 1,
        "editor page",
      ),
      currentTick: integer(p.currentTick ?? 0, 0, total, "edit position"),
      playhead: integer(p.playhead ?? 0, 0, total, "playhead"),
      entryMode: (() => { const mode = p.entryMode ?? "chord"; if (!["step","chord"].includes(mode)) throw Error("Invalid entry mode."); return mode; })(),
      selection: region(p.selection, total, [0, BAR]),
      playRange: region(p.playRange, total, null, true),
      composition, arrangement, suggestions, brief:briefSettings(p.brief??{}),

    };
  }
  function arrangementSettings(value, tracks, total, unique, page=0) {
    if(!value || typeof value!=="object" || Array.isArray(value))throw Error("Invalid arrangement.");
    const refs=new Set(tracks.map(t=>t.id));
    const list=(key,max)=>{const v=value[key]??[];if(!Array.isArray(v)||v.length>max)throw Error("Invalid "+key);return v;};
    const clips=list("clips",4096).map(c=>{
      if(!c||!refs.has(c.trackId))throw Error("Clip track is missing.");
      const out={id:unique(c.id),name:String(c.name??"Phrase").slice(0,48),trackId:c.trackId,startTick:integer(c.startTick,0,total-1,"clip start"),durationTicks:integer(c.durationTicks,1,total,"clip length")};
      if(end(out)>total)throw Error("Clip extends beyond project.");return out;
    });
    for(const t of tracks){const lane=clips.filter(c=>c.trackId===t.id).sort((a,b)=>a.startTick-b.startTick);if(lane.some((c,i)=>i&&c.startTick<end(lane[i-1])))throw Error("Clips overlap on a track.");}
    const sections=list("sections",128).map(c=>{
      if(!c)throw Error("Invalid section.");
      const out={id:unique(c.id),name:String(c.name??"Section").slice(0,48),startTick:integer(c.startTick,0,total-1,"section start"),durationTicks:integer(c.durationTicks,1,total,"section length"),purpose:c.purpose??"hook",density:c.density??"normal",transpose:integer(c.transpose??0,-24,24,"section transpose")};
      if(end(out)>total||!["intro","hook","contrast","breakdown","ending"].includes(out.purpose)||!["sparse","normal","busy"].includes(out.density))throw Error("Invalid section.");return out;
    }).sort((a,b)=>a.startTick-b.startTick);
    if(sections.some((c,i)=>i&&c.startTick<end(sections[i-1])))throw Error("Sections overlap.");
    const selectedTrackIds=list("selectedTrackIds",16);if(selectedTrackIds.some(x=>!refs.has(x))||new Set(selectedTrackIds).size!==selectedTrackIds.length)throw Error("Invalid selected tracks.");
    const selectedClipIds=list("selectedClipIds",4096);if(selectedClipIds.some(x=>!clips.some(c=>c.id===x))||new Set(selectedClipIds).size!==selectedClipIds.length)throw Error("Invalid selected clips.");
    const editBars=integer(value.editBars??4,1,16,"editor zoom");if(![1,2,4,8,16].includes(editBars))throw Error("Invalid editor zoom.");
    const rollStart=integer(value.rollStart??Math.min(page*4*BAR,total-BAR),0,total-1,"editor scroll");if(rollStart%BAR)throw Error("Editor scroll must start at a bar.");
    if(value.multiEdit!==undefined&&typeof value.multiEdit!=="boolean")throw Error("Invalid multi-track mode.");
    return {multiEdit:value.multiEdit??false,clips,sections,endTick:value.endTick==null?null:integer(value.endTick,1,total,"song end"),zoom:integer(value.zoom??48,16,160,"arrangement zoom"),editBars,rollStart,selectedTrackIds,selectedClipIds};
  }
  // Saved proposals retain musical data and seed metadata. Peer recipes remain session-only.
  function suggestionSettings(value) {
    if(!Array.isArray(value)||value.length>24)throw Error("Too many saved suggestions.");
    let count=0;
    function events(notes,length,drums=null) {
      if(!Array.isArray(notes)||notes.length>4096)throw Error("Invalid saved proposal notes.");
      return notes.map(n=>{
        if(!n||++count>100000)throw Error("Saved suggestion shelf is too large.");
        const out={id:typeof n.id==="string"&&n.id.length<=100?n.id:id(),startTick:integer(n.startTick,0,length-1,"proposal start"),durationTicks:integer(n.durationTicks,1,length,"proposal duration"),velocity:number(n.velocity,0,1,"proposal velocity"),articulation:n.articulation??"normal",pitchBend:[]};
        if(end(out)>length||!["normal","staccato"].includes(out.articulation)||(n.pitchBend!==undefined&&(!Array.isArray(n.pitchBend)||n.pitchBend.length)))throw Error("Invalid proposal note.");
        if(n.drumVoice!==undefined){if(drums===false||!drumVoices.includes(n.drumVoice))throw Error("Invalid proposal drum.");out.drumVoice=n.drumVoice;}else{if(drums===true)throw Error("Invalid proposal type.");out.pitch=integer(n.pitch,0,127,"proposal pitch");}
        return out;
      });
    }
    const ref=x=>{if(typeof x!=="string"||!x.length||x.length>100)throw Error("Invalid proposal track.");return x;};
    function bundles(list,length){
      if(!Array.isArray(list)||!list.length||list.length>16)throw Error("Invalid proposal bundle.");
      const out=list.map(b=>{if(!b||!instruments.includes(b.instrument))throw Error("Invalid proposal instrument.");return {trackId:ref(b.trackId),instrument:b.instrument,volume:number(b.volume,0,1,"proposal volume"),sound:soundSettings(b.sound,b.instrument),pan:number(b.pan??0,-1,1,"proposal pan"),role:b.role??"lead",notes:events(b.notes,length,isDrum(b.instrument))};});
      if(new Set(out.map(b=>b.trackId)).size!==out.length||out.some(b=>!["lead","harmony","bass","drums"].includes(b.role)))throw Error("Invalid proposal roles.");return out;
    }
    const ids=new Set();
    return value.map(v=>{
      if(!v||!v.context)throw Error("Invalid saved suggestion.");
      const serial=integer(v.id,1,4294967295,"suggestion ID");if(ids.has(serial))throw Error("Duplicate suggestion ID.");ids.add(serial);
      const c=v.context,settings=compositionSettings(c,MAX_BARS*BAR),length=settings.length,targetTick=integer(c.targetTick,0,MAX_BARS*BAR-length,"proposal destination"),parts=bundles(v.bundles,length),primary=parts[0];
      if(ref(c.trackId)!==primary.trackId)throw Error("Invalid primary proposal track.");
      const lead=c.leadIn??[];if(!Array.isArray(lead)||lead.length>32)throw Error("Proposal lead-in is too long.");
      const leadIn=lead.map(l=>{const len=integer(l.length,1,4*BAR,"lead-in length");return {targetTick:integer(l.targetTick,0,MAX_BARS*BAR-len,"lead-in start"),length:len,bundles:bundles(l.bundles,len)};});
      const context={...settings,trackId:primary.trackId,instrument:primary.instrument,volume:primary.volume,sound:primary.sound,pan:primary.pan,role:primary.role,targetTick,seed:events(c.seed,MAX_BARS*BAR,isDrum(primary.instrument)),leadIn,density:c.density??"normal",sectionTranspose:integer(c.sectionTranspose??0,-24,24,"proposal section transpose")};
      if(!["sparse","normal","busy"].includes(context.density))throw Error("Invalid proposal density.");
      return {id:serial,name:String(v.name??"Saved proposal").slice(0,80),randomSeed:integer(v.randomSeed,0,4294967295,"proposal random seed"),context,bundles:parts,notes:primary.notes,pairId:parts[1]?.trackId??"",instrument:primary.instrument,volume:primary.volume,sound:primary.sound,pan:primary.pan};
    });
  }
  const chordQualities = {major:[0,4,7],minor:[0,3,7],dim:[0,3,6],sus2:[0,2,7],sus4:[0,5,7],dominant7:[0,4,7,10],minor7:[0,3,7,10]};
  function compositionSettings(value, total) {
    if (!value || typeof value !== "object" || Array.isArray(value)) throw Error("Invalid composition settings.");
    const c = value;
    const choice = (key, values, fallback) => {
      const v = c[key] ?? fallback;
      if (!values.includes(v)) throw Error("Invalid composition " + key);
      return v;
    };
    const locks = c.locks ?? {};
    if (!locks || typeof locks !== "object" || Array.isArray(locks)) throw Error("Invalid motif locks.");
    for (const k of ["rhythm","contour","pitches"]) if (locks[k] !== undefined && typeof locks[k] !== "boolean") throw Error("Invalid motif lock.");
    let motif = null;
    if (c.motif != null) {
      const m = c.motif;
      if (!m || !Array.isArray(m.notes) || !m.notes.length || m.notes.length>16) throw Error("A motif needs 1–16 notes.");
      const length = integer(m.length,1,4*BAR,"motif length");
      const kind = m.kind ?? "pitched";
      if (!["pitched","drums"].includes(kind)) throw Error("Invalid motif kind.");
      const notes = m.notes.map(n => {
        if (!n || typeof n !== "object") throw Error("Invalid motif note.");
        const out = {startTick:integer(n.startTick,0,length-1,"motif start"),durationTicks:integer(n.durationTicks,1,length,"motif duration"),velocity:number(n.velocity,0,1,"motif velocity"),articulation:n.articulation??"normal"};
        if (end(out)>length || !["normal","staccato"].includes(out.articulation)) throw Error("Invalid motif note.");
        if (kind === "drums") {if(!drumVoices.includes(n.drumVoice))throw Error("Invalid motif drum.");out.drumVoice=n.drumVoice;}
        else out.pitch=integer(n.pitch,0,127,"motif pitch");
        return out;
      });
      motif={kind,length,notes:sort(notes)};
    }
    const chords = c.chords ?? [];
    if (!Array.isArray(chords) || chords.length>MAX_BARS) throw Error("Invalid chord lane.");
    const lane = chords.map(ch => {
      if (!ch || typeof ch !== "object") throw Error("Invalid chord.");
      const startTick=integer(ch.startTick,0,total-1,"chord start"),durationTicks=integer(ch.durationTicks,1,total,"chord duration");
      if (startTick%BAR || durationTicks!==BAR || startTick+durationTicks>total || !Object.hasOwn(chordQualities,ch.quality)) throw Error("Chords must occupy one bar with a known quality.");
      return {startTick,durationTicks,root:integer(ch.root,0,11,"chord root"),quality:ch.quality};
    }).sort((a,b)=>a.startTick-b.startTick);
    if(lane.some((ch,i)=>i&&ch.startTick===lane[i-1].startTick))throw Error("Overlapping chords.");
    return {
      root:integer(c.root??0,0,11,"key"),
      scale:choice("scale",["major","minor","pentatonic","dorian"],"major"),
      length:integer(c.length??BAR,STEP,4*BAR,"suggestion length"),
      action:choice("action",["continue","answer","fill","resolve"],"continue"),
      groove:choice("groove",["straight","syncopated","lurch","sparse"],"straight"),
      chromatic:choice("chromatic",["scale","controlled","manual"],"scale"),
      mood:choice("mood",["neutral","hopeful","dark","peaceful","playful"],"neutral"),
      density:choice("density",["sparse","normal","busy"],"normal"),
      leadRegister:choice("leadRegister",["wide","low","middle","high"],"wide"),
      purpose:choice("purpose",["hook","contrast","ending"],"hook"),
      humanize:integer(c.humanize??0,0,12,"timing variation"),
      randomSeed:integer(c.randomSeed??12345,0,4294967295,"generation seed"),
      motif,locks:{rhythm:locks.rhythm??false,contour:locks.contour??false,pitches:locks.pitches??false},chords:lane,
    };
  }
  function briefSettings(value) {
    if(!value||typeof value!=="object"||Array.isArray(value))throw Error("Invalid composition brief.");
    const allowed=["title","description","mood","root","scale","bpm","groove","density","palette","leadRegister","chromatic","form","motif","randomSeed"];
    if(Object.keys(value).some(k=>!allowed.includes(k)))throw Error("Unknown composition brief field.");
    const text=(key,fallback,max)=>{const v=value[key]??fallback;if(typeof v!=="string"||v.length>max)throw Error("Invalid brief "+key);return v;};
    const choice=(key,values,fallback)=>{const v=value[key]??fallback;if(!values.includes(v))throw Error("Invalid brief "+key);return v;};
    const motif=compositionSettings({motif:value.motif??null},MAX_BARS*BAR).motif;
    if(motif&&motif.kind!=="pitched")throw Error("A brief motif must use pitched notes.");
    return {title:text("title","Untitled brief",80),description:text("description","",2000),mood:choice("mood",["hopeful","dark","peaceful","playful"],"hopeful"),root:integer(value.root??0,0,11,"brief key"),scale:choice("scale",["major","minor","pentatonic","dorian"],"major"),bpm:integer(value.bpm??110,45,220,"brief tempo"),groove:choice("groove",["straight","syncopated","lurch","sparse"],"straight"),density:choice("density",["sparse","normal","busy"],"normal"),palette:choice("palette",["chip","soft","acoustic","jazz","jazzBrush","folk","chamber","nocturne","electric","pizzicato"],"chip"),leadRegister:choice("leadRegister",["low","middle","high"],"middle"),chromatic:choice("chromatic",["scale","controlled","manual"],"scale"),form:choice("form",["none","short","fourMinute"],"short"),randomSeed:integer(value.randomSeed??731,0,4294967295,"brief seed"),motif};
  }
  // A range copy clips notes at its boundaries and uses relative start positions.
  function copyRegion(notes, a, b) {
    return notes
      .filter((n) => overlaps(n, a, b))
      .map((n) => ({
        ...clone(n),
        id: id(),
        startTick: Math.max(n.startTick, a) - a,
        durationTicks: Math.min(end(n), b) - Math.max(n.startTick, a),
      }));
  }
  // Clear only the selected part of a sustain, retaining notes on either side.
  function clearRegion(notes, a, b) {
    const out = [];
    for (const n of notes) {
      if (!overlaps(n, a, b)) {
        out.push(n);
        continue;
      }
      if (n.startTick < a)
        out.push({ ...clone(n), durationTicks: a - n.startTick });
      if (end(n) > b)
        out.push({
          ...clone(n),
          id: id(),
          startTick: b,
          durationTicks: end(n) - b,
        });
    }
    return sort(out);
  }
  function insert(notes, clip, target, length, replace = true) {
    const base = replace ? clearRegion(notes, target, target + length) : notes;
    return sort([
      ...base,
      ...clip.map((n) => ({
        ...clone(n),
        id: id(),
        startTick: n.startTick + target,
      })),
    ]);
  }
  function midiName(p) {
    return (
      ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"][
        p % 12
      ] +
      (Math.floor(p / 12) - 1)
    );
  }
  return {
    PPQ,
    STEP,
    BAR,
    VERSION,
    MAX_BARS,
    DEFAULT_BARS,
    compositionSettings, briefSettings, chordQualities, arrangementSettings, suggestionSettings,
    instruments, instrumentCatalog, soundTypes, aiInstrumentAllowed: id => instrumentCatalog.some(s => s.id === id && s.aiAllowed !== false), isDrum, isReed, isGuitar, playerFor, playerAllows, soundDefaults, soundSettings, soundPresets,
    drumVoices,
    id,
    clone,
    note,
    track,
    defaultProject,
    validate,
    end,
    overlaps,
    sort,
    copyRegion,
    clearRegion,
    insert,
    midiName,
  };
})();




