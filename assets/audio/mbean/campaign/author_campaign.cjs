#!/usr/bin/env node
/* Deterministic score compiler. Run: node assets/audio/mbean/campaign/author_campaign.cjs
 * Musical source is phrases.cjs. A token is concert pitch:quarter-note-length;
 * _:length is a rest. Every string is exactly one fixed 4/4 MBean1 bar.
 * No randomness, sampled assets, generated melody, or copied legacy score.
 */
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const crypto = require('node:crypto');
const DIR = __dirname;
const BAR = 1920;
const PPQ = 480;
let serial = 0;
const sandbox = {globalThis: {crypto: {randomUUID: () => `author-id-${++serial}`}}};
vm.createContext(sandbox);
const modelPath = path.join(DIR, '../renderer/model.js');
vm.runInContext(fs.readFileSync(modelPath, 'utf8') + '\nglobalThis.Model = MusicModel;', sandbox);
const M = sandbox.globalThis.Model;
const definitions = require('./phrases.cjs');
const manifest = JSON.parse(fs.readFileSync(path.join(DIR, 'manifest.json'), 'utf8'));
const pc = {C:0,D:2,E:4,F:5,G:7,A:9,B:11};
function midi(s) {
  const m = /^([A-G])([#b]?)(-?\d)$/.exec(s);
  if (!m) throw Error(`Invalid concert pitch ${s}`);
  return (Number(m[3])+1)*12+pc[m[1]]+(m[2]==='#'?1:m[2]==='b'?-1:0);
}
function parseBar(text) {
  let beat = 0;
  const events=[];
  for(const token of text.trim().split(/\s+/)) {
    const [pitch,length] = token.split(':');
    const duration=Number(length);
    if(!Number.isFinite(duration)||duration<=0||!Number.isInteger(duration*PPQ)) throw Error(`Invalid duration ${token}`);
    if(pitch!=='_') events.push({startTick:Math.round(beat*PPQ),durationTicks:Math.round(duration*PPQ),pitch:midi(pitch)});
    beat += duration;
  }
  if(beat!==4) throw Error(`Bar has ${beat} beats, expected 4: ${text}`);
  return events;
}
// Open bass foundation plus compact upper shells, all concert pitches.
// Suspended sonorities intentionally omit their thirds.
const chordData = {
  D:[38,'major','F#4 A4 D5'], Dm:[38,'minor','F4 A4 D5'], Dsus:[38,'sus4','G4 A4 D5'],
  Bm:[35,'minor','F#4 B4 D5'], B:[35,'major','F#4 B4 D#5'], B7:[35,'dominant7','A3 D#4 F#4'],
  G:[31,'major','G4 B4 D5'], Gm:[31,'minor','G4 Bb4 D5'], G7:[31,'dominant7','F4 B4 D5'], Gsus:[31,'sus4','G4 C5 D5'],
  A:[33,'major','E4 A4 C#5'], Am:[33,'minor','E4 A4 C5'], A7:[33,'dominant7','G4 A4 C#5'], Asus:[33,'sus4','E4 A4 D5'],
  E:[40,'major','E4 G#4 B4'], Em:[40,'minor','E4 G4 B4'], E7:[40,'dominant7','D4 G#4 B4'], Esus:[40,'sus4','E4 A4 B4'],
  C:[36,'major','E4 G4 C5'], Cm:[36,'minor','Eb4 G4 C5'], Csus:[36,'sus4','F4 G4 C5'], C7:[36,'dominant7','E4 Bb4 C5'],
  F:[29,'major','F4 A4 C5'], Fm:[29,'minor','F4 Ab4 C5'], Fsus:[29,'sus4','F4 Bb4 C5'],
  Bb:[34,'major','F4 Bb4 D5'], Eb:[39,'major','G4 Bb4 Eb5'], Ab:[32,'major','Ab4 C5 Eb5'],
  Fsm:[30,'minor','F#4 A4 C#5'], Fs:[30,'major','F#4 A#4 C#5'], Fssus:[30,'sus4','F#4 B4 C#5'],
  Csm:[37,'minor','E4 G#4 C#5'], Cs:[37,'major','E#4 G#4 C#5'], Cs7:[37,'dominant7','E#4 B4 C#5'],
  Gsm:[32,'minor','G#4 B4 D#5'], Gsdim:[32,'dim','F4 B4 D5'],
  Bbdim:[34,'dim','E4 G4 Bb4'], Bdim:[35,'dim','F4 B4 D5']
};
// Rhythm is authored per scene. Entries are [onset in beats, gate, root/fifth/octave].
const grooves = {
  coast:{bass:[[0,.65,0],[1.5,.35,7],[2.5,.4,12],[3.5,.25,7]],kick:[0,1.5,2.5],snare:[1,3],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[0,2.5]},
  blockade:{bass:[[0,.4,0],[.75,.3,0],[1.5,.4,7],[2.5,.4,0],[3.25,.3,12]],kick:[0,.75,2.5],snare:[1.5,3.5],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[0,1.5,3]},
  ice:{bass:[[0,1.3,0],[2.5,.7,7]],kick:[0,2.5],snare:[2],hats:[.5,1.5,2.5,3.5],comp:[0]},
  rime:{bass:[[0,.35,0],[.5,.2,12],[1.75,.2,7],[2.5,.3,0],[3.5,.2,7]],kick:[0,1.75,2.5],snare:[1,3.25],hats:[.5,.75,1.5,2,2.5,2.75,3.5],comp:[.5,2.5]},
  trench:{bass:[[0,.55,0],[1,.35,7],[2,.55,0],[3,.35,7],[3.5,.25,12]],kick:[0,2,3.5],snare:[1,3],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[0,2]},
  sovereign:{bass:[[0,.35,0],[.5,.25,0],[1,.45,7],[2,.35,0],[2.5,.25,12],[3.5,.2,7]],kick:[0,.5,2,2.5],snare:[1,3],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[0,1.5,2.5]},
  treads:{bass:[[0,.5,0],[.75,.2,0],[1.5,.3,7],[2,.5,0],[2.75,.2,12],[3.5,.25,7]],kick:[0,.75,2,2.75],snare:[1,3],hats:[.25,.75,1.5,2.25,2.75,3.5],comp:[.75,2.75]},
  maw:{bass:[[0,.65,0],[1.5,.35,0],[2,.65,7],[3.5,.25,0]],kick:[0,1.5,2,3.5],snare:[1,3],hats:[.5,1.5,2.5,3.5],comp:[0,2]},
  orbit:{bass:[[0,1.1,0],[1.5,.7,7],[3,.55,12]],kick:[0,2.5],snare:[2],hats:[.5,1.5,2.5,3.5],comp:[0,2.5]},
  harrow:{bass:[[.5,.35,0],[1.5,.35,7],[2.5,.35,0],[3.25,.25,12]],kick:[.5,2.5,3.25],snare:[1,3],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[.5,2.5]},
  lightning:{bass:[[0,.35,0],[.75,.3,7],[1.5,.35,12],[2.5,.3,0],[3.25,.25,7]],kick:[0,.75,1.5,2.5],snare:[1,3],hats:[0,.5,1,1.5,2,2.5,3,3.5],comp:[0,1.5,2.5]},
  crown:{bass:[[0,.3,0],[.25,.2,12],[1.5,.35,7],[2,.3,0],[2.75,.2,0],[3.5,.2,12]],kick:[0,.25,1.5,2.75],snare:[1,3.5],hats:[0,.5,1,1.5,2,2.5,3,3.5,3.75],comp:[0,1.5,3]}
};
const audit=[];
const phraseMap=[];
for(const cue of manifest.cues) {
  const d = definitions[cue.id];
  if(!d) throw Error(`Missing composition ${cue.id}`);
  if(d.phrases.length*4!==cue.bars) throw Error(`${cue.id} phrase count disagrees with manifest`);
  let nserial=0;
  const p=M.defaultProject();
  p.bpm=cue.bpm; p.bars=cue.bars; p.selection=[0,4*BAR]; p.playRange=[0,cue.bars*BAR];
  function tr(label, instrument, volume, role, sound, pan=0) {
    const t=M.track(label,instrument,volume); t.id=`${cue.id}-${role}-${p.tracks.length}`;
    t.role=role;t.pan=pan;t.sound={...t.sound,...sound};p.tracks.push(t);return t;
  }
  p.tracks=[];
  const lead=tr('Flight theme','pulseLead',d.leadVolume??.55,'lead',d.leadSound??{},-.06);
  const pad=tr('Open harmonic shells','pulseLead',.20,'harmony',{attack:.075,decay:.14,sustain:.44,release:.045,pulseWidth:.5,cutoff:2100,vibratoDepth:0},.10);
  const bass=tr('Bass foundation','chipBass',.43,'bass',{attack:.006,decay:.11,sustain:.65,release:.035,cutoff:d.bassCutoff??1300,bassWave:d.bassWave??'triangle',vibratoDepth:0});
  const drums=tr('Scene pulse','chipDrums',d.drumVolume??.36,'auto',{release:.04},.025);
  let answer=null;
  if(d.phrases.some(x=>x.answers))answer=tr('Motif answers',d.answerVoice??'pulseLead',.25,'harmony',{attack:.012,decay:.09,sustain:.34,release:.04,pulseWidth:.125,cutoff:3300,vibratoDepth:0},.16);
  function put(t,at,len,pitch,velocity) {
    const event=M.note(Math.round(at),Math.max(1,Math.round(len)),pitch,velocity);
    event.id=`${cue.id}-n${++nserial}`;
    t.notes.push(event);return event;
  }
  function drum(at,voice,velocity) {
    // Drum renderer uses fixed release tails, so the last beat stays free.
    if(at>=(cue.bars*BAR-PPQ))return;
    const event=put(drums,at,60,48,velocity);delete event.pitch;event.drumVoice=voice;
  }
  const allMelody=[];
  d.phrases.forEach((phrase,index)=> {
    const start=index*4*BAR;
    const density=phrase.density??'normal';
    const sparse=density==='sparse';
    const energy=phrase.energy??(sparse?.74:1);
    const g=grooves[phrase.groove??d.groove];
    if(!g)throw Error(`Unknown groove for ${cue.id}`);
    const chordNames=phrase.chords.trim().split(/\s+/);
    if(chordNames.length!==4||phrase.bars.length!==4)throw Error(`Expected four bars in ${cue.id}/${phrase.name}`);
    const localMelody=phrase.bars.flatMap((s,bar)=>parseBar(s).map(n=>({...n,startTick:n.startTick+bar*BAR})));
    const signature=localMelody.map(n=>[n.startTick,n.durationTicks,n.pitch-localMelody[0].pitch]);
    const sig=JSON.stringify(signature);
    phraseMap.push({cue:cue.id,phrase:index+1,name:phrase.name,startBar:index*4+1,endBar:index*4+4,startTick:start,endTick:start+4*BAR,function:phrase.function??'hook',change:phrase.change,harmony:chordNames,melody:phrase.bars,answers:phrase.answers??null,density,signature:crypto.createHash('sha256').update(sig).digest('hex')});
    p.arrangement.sections.push({id:`${cue.id}-section-${index}`,name:phrase.name,startTick:start,durationTicks:4*BAR,purpose:phrase.function??'hook',density,transpose:0});
    p.arrangement.clips.push({id:`${cue.id}-clip-${index}`,name:phrase.name,trackId:lead.id,startTick:start,durationTicks:4*BAR});
    const peak=localMelody.reduce((v,n)=>Math.max(v,n.pitch),0);
    localMelody.forEach((n,i)=> {
      // The written durations express rhythm; a small explicit gate gap clears releases.
      const gap=Math.ceil((lead.sound.release+.006)*cue.bpm/60*PPQ);
      const gate=Math.max(24,n.durationTicks-gap);
      const accent=n.startTick%PPQ===0?.84:.74;
      const shape=n.pitch===peak?.05:i===localMelody.length-1?-.04:0;
      // Pulse fundamentals become perceptually exposed above E6. Taper their
      // attacks instead of flattening the deliberately written climax contour.
      const registerGain=n.pitch>=94?.80:n.pitch>88?.88:1;
      const note=put(lead,start+n.startTick,gate,n.pitch,Math.min(.96,(accent+shape)*energy*registerGain));
      allMelody.push(note);
    });
    if(phrase.answers) {
      if(phrase.answers.length!==4)throw Error('Answer needs four bars');
      phrase.answers.forEach((bar,b)=>parseBar(bar).forEach(n=>put(answer,start+b*BAR+n.startTick,Math.max(24,n.durationTicks-60),n.pitch,.62*energy)));
    }
    chordNames.forEach((name,b)=> {
      const c=chordData[name];if(!c)throw Error(`Unknown chord ${name}`);
      const at=start+b*BAR;
      const root=c[0];
      const shell=c[2].split(' ').map(midi);
      p.composition.chords.push({startTick:at,durationTicks:BAR,root:root%12,quality:c[1]});
      // A sparse section removes the backbeat and uses a single bass foundation.
      const bassEvents=sparse?[[0,2.6,0]]:g.bass;
      bassEvents.forEach(([beat,gate,interval],i)=>put(bass,at+beat*PPQ,gate*PPQ,root+interval,(i===0?.81:.66)*energy));
      const comp=sparse?[0]:g.comp;
      comp.forEach((beat,i)=> {
        const next=comp[i+1]??4;
        const gate=sparse?2.7:Math.min(next-beat-.12,d.groove==='ice'?2.9:.8);
        // Omit a shell member only where it would sustain an exposed minor ninth
        // under a written accented/long melody. Melody and harmony remain authored.
        shell.forEach(pitch=> {
          const a=at+beat*PPQ, z=a+gate*PPQ;
          const clash=allMelody.some(n=>n.startTick<z&&n.startTick+n.durationTicks>a&&n.durationTicks>=.7*PPQ&&n.pitch-pitch===13);
          if(!clash)put(pad,a,gate*PPQ,pitch,(i===0?.61:.50)*energy);
        });
      });
      if(sparse) {drum(at,'kick',.44);if(b%2===1)drum(at+2.5*PPQ,'closedHat',.27);}
      else {
        g.kick.forEach((beat,i)=>drum(at+beat*PPQ,'kick',(i===0?.80:.61)*energy));
        g.snare.forEach(beat=>drum(at+beat*PPQ,'snare',.57*energy));
        g.hats.forEach((beat,i)=>drum(at+beat*PPQ,'closedHat',(i%2?.32:.40)*energy));
        if(b===0&&index%2===0)drum(at,'crash',.30*energy);
        if(b===3&&index<d.phrases.length-1) {drum(at+3*PPQ,'tom',.49*energy);if(density==='busy')drum(at+3.5*PPQ,'tom',.44*energy);}
      }
    });
  });
  p.arrangement.endTick=cue.bars*BAR;
  p.arrangement.editBars=4;
  p.arrangement.selectedTrackIds=[lead.id];
  p.composition.root=d.root;
  p.composition.scale=d.scale;
  p.composition.groove=d.briefGroove??'syncopated';
  p.composition.chromatic='manual';
  p.composition.humanize=0;
  const motif=allMelody.filter(n=>n.startTick<2*BAR).slice(0,16).map(({id,pitchBend,...n})=>n);
  p.composition.motif={kind:'pitched',length:2*BAR,notes:motif};
  p.brief={...p.brief,title:cue.title,description:`${cue.role}. ${cue.tonality}. ${cue.form}. Original manually authored melody and harmony; phrase map and source accompany this project.`,mood:cue.boss?'dark':d.mood??'hopeful',root:d.root,scale:d.scale,bpm:cue.bpm,groove:d.briefGroove??'syncopated',density:'normal',palette:'chip',chromatic:'manual',form:'none',motif:p.composition.motif};
  const validated=M.validate(p);
  const ownPhrases=phraseMap.filter(x=>x.cue===cue.id);
  for(let i=2;i<ownPhrases.length;i++)if(ownPhrases[i].signature===ownPhrases[i-1].signature&&ownPhrases[i].signature===ownPhrases[i-2].signature)throw Error(`Undeveloped third phrase ${cue.id}/${i}`);
  // All sounding synth releases clear the loop; noise/kick tails stop by last beat.
  const totalSeconds=cue.bars*4*60/cue.bpm;
  for(const t of validated.tracks.filter(t=>t.instrument!=='chipDrums')) for(const n of t.notes) {
    const end=(n.startTick+n.durationTicks)/PPQ*60/cue.bpm+t.sound.release+.005;
    if(end>totalSeconds+.00001)throw Error(`Release crosses seam ${cue.id}/${t.name}`);
  }
  const text=JSON.stringify(validated,null,2)+'\n';
  fs.writeFileSync(path.join(DIR,cue.file),text);
  const pitches=lead.notes.map(n=>n.pitch);
  const high=lead.notes.filter(n=>n.pitch>=91);
  const friction=[];
  for(const n of lead.notes) for(const h of pad.notes) {
    if(![1,13,25].includes(Math.abs(n.pitch-h.pitch)))continue;
    const a=Math.max(n.startTick,h.startTick);
    const z=Math.min(n.startTick+n.durationTicks+lead.sound.release*cue.bpm/60*PPQ,h.startTick+h.durationTicks+pad.sound.release*cue.bpm/60*PPQ);
    const seconds=(z-a)/PPQ*60/cue.bpm;
    if(seconds>=.17)friction.push({bar:Math.floor(a/BAR)+1,melody:n.pitch,support:h.pitch,seconds});
  }
  audit.push({id:cue.id,bpm:cue.bpm,bars:cue.bars,seconds:totalSeconds,tracks:validated.tracks.length,notes:validated.tracks.reduce((n,t)=>n+t.notes.length,0),foregroundRange:[Math.min(...pitches),Math.max(...pitches)],upperSupportMaximum:Math.max(...pad.notes.map(n=>n.pitch)),highPulseEvents:high.length,longestHighPulseGateSeconds:Math.max(0,...high.map(n=>n.durationTicks/PPQ*60/cue.bpm)),exposedSemitoneReview:friction,uniquePhraseSignatures:new Set(ownPhrases.map(x=>x.signature)).size,phraseCount:ownPhrases.length,sha256:crypto.createHash('sha256').update(text).digest('hex'),modelValidation:'pass',releaseSeam:'pass'});
  console.log(`${cue.id}: ${cue.bars} bars, ${totalSeconds.toFixed(3)}s, ${audit.at(-1).notes} notes, validated`);
}
fs.writeFileSync(path.join(DIR,'phrase-map.json'),JSON.stringify({version:1,notation:'concert pitch:quarter-note length; _:length is a rest; each string is a 4/4 bar',phrases:phraseMap},null,2)+'\n');
fs.writeFileSync(path.join(DIR,'score-audit.json'),JSON.stringify({version:1,rendererModel:'../renderer/model.js',modelSha256:crypto.createHash('sha256').update(fs.readFileSync(modelPath)).digest('hex'),source:'phrases.cjs',sourceSha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(DIR,'phrases.cjs'))).digest('hex'),method:'MBean1 model validation plus note/phrase/release inspection. Audio rendering and playback are separate.',highPulseTreatment:'Velocity multiplied by 0.88 above MIDI88 and 0.80 at MIDI94 and above; no register transposition.',frictionReview:'Only one >=0.17s lead/support semitone compound: Tempest flight bar24 F#6 over E#4 for 0.214s, a weak-eighth passing fourth resolving to E#6. No >=0.25s exposures.',cues:audit},null,2)+'\n');
