// Local synth voices: no remote packs. Web Audio band-limits the periodic pulse.
function pulseWave(ctx,width){
  const real=new Float32Array(129),imag=new Float32Array(129);
  for(let n=1;n<129;n++){real[n]=2*Math.sin(2*Math.PI*n*width)/(Math.PI*n);imag[n]=2*(1-Math.cos(2*Math.PI*n*width))/(Math.PI*n);}
  return ctx.createPeriodicWave(real,imag);
}
function chipEnvelope(g,when,gate,level,s){
  const attack=Math.min(s.attack,gate*.35),decay=Math.min(s.decay,gate*.35),sustain=level*s.sustain;
  g.gain.setValueAtTime(0,when);g.gain.linearRampToValueAtTime(level,when+attack);g.gain.linearRampToValueAtTime(sustain,when+attack+decay);g.gain.setValueAtTime(sustain,when+gate);g.gain.linearRampToValueAtTime(0,when+gate+s.release);
}
function chipNoise(ctx,seconds,id){
  const b=ctx.createBuffer(1,Math.ceil(seconds*ctx.sampleRate),ctx.sampleRate),data=b.getChannelData(0);
  let seed=2166136261;for(const ch of String(id))seed=Math.imul(seed^ch.charCodeAt(0),16777619);
  for(let i=0;i<data.length;i++){seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;data[i]=(seed>>>0)/2147483648-1;}return b;
}
function playChip(event,gate,volume,instrument,ctx,when,settings){
  const s=MusicModel.soundSettings(settings,instrument),voice=event.drumVoice;
  const gain=ctx.createGain(),filter=ctx.createBiquadFilter();let source,lfo,lfoGain,duration=gate+s.release;
  const velocity=Math.pow(event.velocity,instrument==='chipBass'?.8:voice?1.25:1.1),level=volume*velocity;
  if(voice&&['snare','closedHat','openHat','rattle','crash','ride','rideBell','crossStick'].includes(voice)){
    duration={snare:.16+s.release,closedHat:.035+s.release*.2,openHat:.22+s.release,rattle:.10+s.release*.5,crash:.45+s.release,ride:.3+s.release,rideBell:.4+s.release,crossStick:.04+s.release*.2}[voice];
    source=ctx.createBufferSource();source.buffer=chipNoise(ctx,duration,event.id);
    filter.type=['snare','crossStick','rideBell'].includes(voice)?'bandpass':'highpass';filter.frequency.value={snare:1900,closedHat:7000,openHat:5000,rattle:8500,crash:3500,ride:4500,rideBell:2700,crossStick:1000}[voice];filter.Q.value=voice==='snare'?.7:.5;
    gain.gain.setValueAtTime(0,when);gain.gain.linearRampToValueAtTime(level*(voice==='snare'?1.7:.75),when+.002);gain.gain.exponentialRampToValueAtTime(.00001,when+duration);
  }else{
    source=ctx.createOscillator();const freq=440*Math.pow(2,((event.pitch??48)-69)/12);
    filter.type='lowpass';filter.frequency.value=s.cutoff;filter.Q.value=.65;
    if(voice==='kick'||voice==='tom'||instrument==='chipTom'){
      const kick=voice==='kick',base=kick?48:voice==='tom'?115:freq;
      duration=kick?.22+s.release:.30+s.release;
      source.type='sine';source.frequency.setValueAtTime(base*(kick?3.5:1.8),when);source.frequency.exponentialRampToValueAtTime(base,when+(kick?.07:.10));
      gain.gain.setValueAtTime(0,when);gain.gain.linearRampToValueAtTime(level*(kick?2.4:1.9),when+.003);gain.gain.exponentialRampToValueAtTime(.00001,when+duration);
    }else{
      source.frequency.value=freq;
      if(instrument==='chipBass'&&s.bassWave==='triangle')source.type='triangle';else source.setPeriodicWave(pulseWave(ctx,s.pulseWidth));
      chipEnvelope(gain,when,gate,level*(instrument==='chipBass'?1.5:1),s);
      if(s.vibratoDepth>0){lfo=ctx.createOscillator();lfoGain=ctx.createGain();lfo.frequency.value=s.vibratoRate;lfoGain.gain.setValueAtTime(0,when);lfoGain.gain.linearRampToValueAtTime(freq*(Math.pow(2,s.vibratoDepth/12)-1),when+.15);lfo.connect(lfoGain);lfoGain.connect(source.frequency);lfo.start(when);lfo.stop(when+duration+.01);}
    }
  }
  source.connect(filter);filter.connect(gain);gain.connect(voiceOutput||ctx.destination);
  trackVoice(source,gain,ctx,()=>{filter.disconnect();if(lfo){try{lfo.stop();}catch{}lfo.disconnect();lfoGain.disconnect();}});
  source.start(when);source.stop(when+duration+.005);
}
