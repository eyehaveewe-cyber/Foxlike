#!/usr/bin/env node
// Re-render the imported MBean1 score using its original Web Audio renderer.
// Requires Playwright, Chromium and ffmpeg. No sample downloads are performed.
// NODE_PATH may point at the host's Playwright modules; CHROMIUM_PATH is optional.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const {execFileSync} = require('node:child_process');
const {chromium} = require('playwright');
const ROOT = __dirname;
const sections = [
  {file:'bone-lantern-hook', title:'First dance', startBar:8, bars:16},
  {file:'bone-lantern-mirrors', title:'Mirrors after midnight', startBar:40, bars:16},
  {file:'bone-lantern-return', title:'The dancers return', startBar:64, bars:16},
];

async function main() {
  const score = JSON.parse(fs.readFileSync(path.join(ROOT,'bone-lantern-source.json'),'utf8'));
  const browser = await chromium.launch({
    executablePath:process.env.CHROMIUM_PATH || undefined,
    args:['--no-sandbox','--disable-dev-shm-usage','--single-process'],
  });
  const temp = fs.mkdtempSync(path.join(os.tmpdir(),'foxlike-mbean-'));
  const captures = [];
  try {
    const page = await browser.newPage();
    await page.goto('about:blank');
    for(const file of ['model.js','chip-audio.js','audio.js'])
      await page.addScriptTag({path:path.join(ROOT,'renderer',file)});
    for(const section of sections) {
      console.log('Rendering '+section.title);
      const data = await page.evaluate(async ({score,section}) => {
        const p = MusicModel.validate(score);
        const start = section.startBar * MusicModel.BAR;
        const ticks = section.bars * MusicModel.BAR;
        const tracks = p.tracks.map(track => {
          const notes = track.notes.filter(n=>n.startTick>=start && n.startTick<start+ticks);
          return {...track,notes:[0,1,2].flatMap(repeat=>notes.map(n=>({...n,
            startTick:n.startTick-start+repeat*ticks,
            durationTicks:Math.min(n.durationTicks,start+ticks-n.startTick),
          })))};
        });
        // Render three passes; retain the middle pass so prior release tails
        // are present at its start and the loop never cuts them abruptly.
        const seconds=ticks/480*60/p.bpm;
        const ctx=new OfflineAudioContext(2,Math.ceil(seconds*3*44100),44100);
        scheduleEvents(tracks,0,ticks*3,ctx,0,p.bpm).forEach(item=>dispatchEvent(item,ctx));
        const blob=encodeWav(await ctx.startRendering());
        const bytes = new Uint8Array(await blob.arrayBuffer());
        let binary='';
        for(let i=0;i<bytes.length;i+=8192)
          binary+=String.fromCharCode(...bytes.subarray(i,i+8192));
        return {wav:btoa(binary),seconds:ticks/480*60/p.bpm,
          notes:tracks.reduce((sum,t)=>sum+t.notes.length/3,0)};
      },{score,section});
      const wav = Buffer.from(data.wav,'base64');
      const sampleRate=wav.readUInt32LE(24), frameBytes=4;
      const first=Math.round(data.seconds*sampleRate), last=Math.round(data.seconds*sampleRate*2);
      const audio=Buffer.from(wav.subarray(44+first*frameBytes,44+last*frameBytes));
      let peak=0;
      for(let i=0;i<audio.length;i+=2)peak=Math.max(peak,Math.abs(audio.readInt16LE(i))/32768);
      captures.push({...section,audio,peak,seconds:data.seconds,notes:data.notes,sampleRate});
    }
    const gain=0.75/Math.max(...captures.map(c=>c.peak));
    for(const c of captures) {
      for(let i=0;i<c.audio.length;i+=2)
        c.audio.writeInt16LE(Math.round(c.audio.readInt16LE(i)*gain),i);
      const header=Buffer.alloc(44);
      header.write('RIFF',0);header.writeUInt32LE(36+c.audio.length,4);
      header.write('WAVEfmt ',8);header.writeUInt32LE(16,16);
      header.writeUInt16LE(1,20);header.writeUInt16LE(2,22);
      header.writeUInt32LE(c.sampleRate,24);header.writeUInt32LE(c.sampleRate*4,28);
      header.writeUInt16LE(4,32);header.writeUInt16LE(16,34);
      header.write('data',36);header.writeUInt32LE(c.audio.length,40);
      const wavPath=path.join(temp,c.file+'.wav');
      fs.writeFileSync(wavPath,Buffer.concat([header,c.audio]));
      execFileSync('ffmpeg',['-hide_banner','-loglevel','error','-y','-i',wavPath,
        '-c:a','libvorbis','-q:a','4','-metadata','title=The Bone Lantern Ballroom — '+c.title,
        path.join(ROOT,c.file+'.ogg')]);
      console.log(JSON.stringify({file:c.file+'.ogg',seconds:c.seconds,notes:c.notes,
        peak:+(c.peak*gain).toFixed(4),sourceStartBar:c.startBar+1}));
    }
  } finally {
    await browser.close();
    fs.rmSync(temp,{recursive:true,force:true});
  }
}
main().catch(error=>{console.error(error);process.exitCode=1;});
