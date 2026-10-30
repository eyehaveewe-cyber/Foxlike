/* Original concert-pitch score source. Four written bars per musical thought.
 * Each phrase has an authored harmonic route and a heard purpose. Returns keep
 * a recognizable head but change its answer, cadence, rhythm or destination.
 */
'use strict';
const P=(name,chords,bars,change,extra={})=>({name,chords,bars,change,...extra});
module.exports = {
  'terminus_falling_yard': {
    root:0,scale:'minor',groove:'salvage',mood:'dark',leadVolume:.51,drumVolume:.30,
    leadSound:{attack:.018,decay:.13,sustain:.63,release:.05,pulseWidth:.46,vibratoDepth:.11,cutoff:3300},
    phrases:[
      P('Keep the gantry steady','Cm Fm Cm G7',[
        'C5:1.5 G5:.5 Eb5:1 _:1',
        'F5:1 Ab5:.5 C6:.5 Ab5:1 F5:1',
        'G5:1 Eb5:.5 C5:.5 D5:1 Eb5:1',
        'D5:1 B4:1 G4:1 _:1'
      ],'The command pickup doubles its first duration and stays low while the structure is stabilized.',{energy:.82}),
      P('Balance the collapsing frame','Fm Cm Bb G7',[
        'Ab5:1 C6:.5 Ab5:.5 G5:1 F5:1',
        'Eb5:.5 G5:.5 C6:1 Bb5:.5 G5:.5 Eb5:1',
        'F5:1 D5:.5 Bb4:.5 D5:1 F5:1',
        'G5:1 B5:.5 D6:.5 B5:1 G5:1'
      ],'The response alternates a supported upper hold with a low counterweight.',{energy:.84}),
      P('Emergency clamps hold','Ab Fm Cm G7',[
        'C6:1.5 Ab5:.5 Eb5:1 _:1',
        'F5:1 C5:1 Ab4:1 _:1',
        'Eb5:1 G5:1 C6:.5 _:1.5',
        'B5:1 G5:.5 D5:.5 F5:1 _:1'
      ],'Separated notes and reduced density mark controlled progress without a triumphant close.',{function:'breakdown',density:'sparse'}),
      P('Walk the load across','Cm Ab Fm G7',[
        'C5:1 G5:.5 Eb5:.5 G5:1 Bb5:1',
        'C6:.5 Eb6:.5 C6:1 Ab5:1 G5:1',
        'F5:.5 Ab5:.5 C6:.5 Eb6:.5 C6:1 Ab5:1',
        'B5:1 D6:.5 F6:.5 D6:.5 B5:.5 G5:1'
      ],'The augmented command gains shorter replies as stabilization becomes more confident.',{energy:.88}),
      P('A clear evacuation signal','Eb Bb Fm G7',[
        'G5:2 Bb5:1 _:1',
        'D6:1.5 Bb5:.5 F5:1 _:1',
        'Ab5:1 C6:.5 Ab5:.5 F5:1 _:1',
        'D5:1 F5:1 B4:1 _:1'
      ],'A restrained major-side clearing finishes the controlled emergency before the wreck shifts.',{function:'contrast',density:'sparse'}),
      P('The yard begins to fall','Cm Bbdim Ab G7',[
        'C5:.25 G5:.25 Eb5:.5 C6:.5 Bb5:.5 G5:1 Eb5:1',
        'E5:.25 G5:.25 Bb5:.5 E6:.5 G6:.5 E6:1 Bb5:1',
        'C6:.5 Eb6:.5 Ab6:1 G6:.5 Eb6:.5 C6:1',
        'B5:.25 D6:.25 F6:.5 G6:.5 F6:.5 D6:1 B5:1'
      ],'The stable command breaks into a clipped pickup and a diminished rupture.',{groove:'sovereign',density:'busy'}),
      P('Choose the wreck corridor','Fm Cm Bb G7',[
        'F6:.5 C6:.5 Ab5:.5 F5:.5 Ab5:1 C6:1',
        'Eb6:.5 G6:.5 Eb6:.75 C6:.25 G5:1 Eb5:1',
        'D5:.5 F5:.5 Bb5:.5 D6:.5 F6:1 D6:1',
        'F6:.5 D6:.5 B5:.5 G5:.5 D5:1 F5:1'
      ],'An alternating high-and-low escape line reverses the stabilization contour.',{groove:'trench',density:'busy'}),
      P('Under the broken assembly','Ab Bb Cm G7',[
        'Ab5:.25 C6:.25 Eb6:.5 Ab6:.5 G6:.5 Eb6:1 C6:1',
        'D6:.25 F6:.25 Bb6:.5 A6:.5 F6:.5 D6:1 Bb5:1',
        'G5:.5 C6:.5 Eb6:1 D6:.5 C6:.5 G5:1',
        'B5:.5 D6:.5 G6:.75 F6:.25 D6:.5 B5:.5 G5:1'
      ],'Escape fragments crest at a short B-flat and fall through the unstable command harmony.',{groove:'sovereign',density:'busy'}),
      P('The command finds an exit','Cm Fm Ab G7',[
        'C5:.75 G5:.25 Eb5:.5 G5:.5 Bb5:.5 C6:.5 Eb6:1',
        'C6:.5 Ab5:.5 F5:1 Ab5:.5 C6:.5 F6:1',
        'Eb6:.75 C6:.25 Ab5:.5 G5:.5 Eb5:1 C5:1',
        'D5:.5 G5:.5 B5:1 D6:.5 F6:.5 G6:1'
      ],'The original command rhythm returns, with a new climbing answer aimed toward the exit.',{groove:'trench'}),
      P('Clear of the falling yard','Fm Ab Cm G7',[
        'C6:1 Ab5:.5 F5:.5 G5:.5 Ab5:.5 C6:1',
        'Eb6:.5 C6:.5 Ab5:1 G5:.5 Eb5:.5 C5:1',
        'G5:1 Eb5:.5 C5:.5 D5:1 Eb5:1',
        'F5:.5 D5:.5 B4:1 G4:1 _:1'
      ],'The exit narrows to the low command register and leaves the emergency loop open.',{function:'ending',groove:'trench'})
    ]
  },
  'tempest_stormbreak': {
    root:6,scale:'dorian',groove:'forecast',mood:'hopeful',leadVolume:.51,drumVolume:.29,
    leadSound:{attack:.018,decay:.10,sustain:.58,release:.045,pulseWidth:.43,vibratoDepth:.10,cutoff:3900},
    answerSound:{attack:.02,decay:.12,sustain:.42,release:.04,pulseWidth:.25,cutoff:2800},
    phrases:[
      P('Share the weather call','Fsm B A Cs7',[
        'F#5:.5 A5:.5 C#6:1 _:2',
        'B5:1 D#6:.5 F#6:.5 _:2',
        'E6:.75 C#6:.25 A5:1 _:2',
        'G#5:.5 B5:.5 E#6:1 _:2'
      ],'The storm spark broadens into a two-beat call; another flight answers in the spaces.',{answers:[
        '_:2 A5:.5 G#5:.5 F#5:1',
        '_:2 F#5:.5 D#5:.5 B4:1',
        '_:2 C#5:.5 E5:.5 A5:1',
        '_:2 C#5:.5 E#5:.5 G#5:1'
      ]}),
      P('Rivals learn the same lane','Fsm Gsm B Cs7',[
        'C#6:1 A5:.5 F#5:.5 _:2',
        'G#5:.5 B5:.5 D#6:1 _:2',
        'F#6:.5 D#6:.5 B5:1 A5:.5 G#5:.5 F#5:1',
        'E#5:1 G#5:.5 B5:.5 _:2'
      ],'The answer becomes the next call; natural sixths distinguish forecast hope from the original minor storm.',{answers:[
        '_:2 F#5:.5 G#5:.5 A5:1',
        '_:2 D#5:.5 F#5:.5 G#5:1',
        '_:4',
        '_:2 B5:.5 G#5:.5 E#5:1'
      ]}),
      P('Forecast the first gap','A E B Fsm',[
        'C#6:.5 E6:.5 A6:1 G#6:.5 E6:.5 C#6:1',
        'B5:.5 G#5:.5 E5:1 _:2',
        'D#6:.75 F#6:.25 B6:.5 F#6:.5 D#6:1 B5:1',
        'A5:1 C#6:.5 F#6:.5 _:2'
      ],'A major-side clearing opens the shared route; one high B marks the forecast crest.',{function:'contrast',answers:[
        '_:4',
        '_:2 G#4:.5 B4:.5 E5:1',
        '_:4',
        '_:2 E5:.5 C#5:.5 A4:1'
      ]}),
      P('Storm hands across the wing','Bm D Fsm Cs7',[
        'B5:.25 D6:.25 F#6:.5 D6:.5 B5:.5 _:2',
        'F#5:.5 A5:.5 D6:1 C#6:.5 A5:.5 F#5:1',
        'C#6:1 A5:.5 F#5:.5 _:2',
        'B5:.5 C#6:.5 E#6:.5 G#6:.5 _:2'
      ],'Borrowed minor-weather harmony tightens the shared call before the corridor opens.',{density:'busy',answers:[
        '_:2 F#5:.5 D5:.5 B4:1',
        '_:4',
        '_:2 A5:.5 G#5:.5 F#5:1',
        '_:2 G#5:.5 E#5:.5 C#5:1'
      ]}),
      P('The safe corridor is real','Fsm A B Fsm',[
        'A5:2 C#6:1 _:1',
        'E6:1.5 C#6:.5 A5:1 _:1',
        'D#6:1 F#6:.5 D#6:.5 B5:1 _:1',
        'C#6:1 A5:.5 F#5:.5 _:2'
      ],'Long Dorian tones and a quiet foundation reveal an actual calm corridor.',{function:'breakdown',density:'sparse',answers:[
        '_:3 F#5:.5 _:0.5',
        '_:3 E5:.5 _:0.5',
        '_:3 F#5:.5 _:0.5',
        '_:2 A4:.5 C#5:.5 F#5:1'
      ]}),
      P('Recover the other flight','B Gsm Fsm Cs7',[
        'B5:1 F#5:.5 D#5:.5 _:2',
        'D#5:.5 G#5:.5 B5:1 _:2',
        'A5:.75 C#6:.25 F#6:1 E6:.5 C#6:.5 A5:1',
        'G#5:1 E#5:.5 C#5:.5 _:2'
      ],'A low rescue call is answered upward before both parts regain the corridor.',{function:'contrast',answers:[
        '_:2 F#4:.5 B4:.5 D#5:1',
        '_:2 B5:.5 G#5:.5 D#5:1',
        '_:4',
        '_:2 C#5:.5 E#5:.5 G#5:1'
      ]}),
      P('Intertwined climb','A B Fsm Cs7',[
        'E6:.5 C#6:.5 A5:1 _:2',
        'D#6:.5 F#6:.5 B6:.5 A6:.5 F#6:1 D#6:1',
        'F#6:.75 E6:.25 C#6:.5 A5:.5 _:2',
        'E#6:.5 G#6:.5 B6:1 G#6:.5 E#6:.5 C#6:1'
      ],'The flights exchange complete climbs instead of doubling the same high line.',{density:'busy',answers:[
        '_:2 A5:.5 C#6:.5 E6:1',
        '_:4',
        '_:2 A4:.5 C#5:.5 F#5:1',
        '_:4'
      ]}),
      P('Forecast the return crossing','D E B Cs7',[
        'F#6:1 D6:.5 A5:.5 F#5:1 A5:1',
        'B5:.5 E6:.5 G#6:1 _:2',
        'F#6:.5 D#6:.5 B5:1 A5:.5 G#5:.5 F#5:1',
        'E#5:.75 G#5:.25 C#6:1 _:2'
      ],'A borrowed D front passes through E into a brighter B forecast; each voice keeps its own landing.',{answers:[
        '_:4',
        '_:2 G#5:.5 E5:.5 B4:1',
        '_:4',
        '_:2 B5:.5 G#5:.5 E#5:1'
      ]}),
      P('A shared call returns changed','Fsm B A Cs7',[
        'F#5:.5 A5:.5 C#6:.5 F#6:.5 _:2',
        'F#6:1 D#6:.5 B5:.5 _:2',
        'C#6:.5 E6:.5 A6:1 E6:.5 C#6:.5 A5:1',
        'G#5:.5 B5:.5 C#6:1 _:2'
      ],'The opening call gains a higher destination; its partner now answers downward through a different register.',{answers:[
        '_:2 E6:.5 C#6:.5 A5:1',
        '_:2 A5:.5 F#5:.5 D#5:1',
        '_:4',
        '_:2 E#6:.5 C#6:.5 B5:1'
      ]}),
      P('Leave the corridor open','B A Fsm Cs7',[
        'D#6:1 B5:.5 F#5:.5 D#5:1 F#5:1',
        'E5:.5 A5:.5 C#6:1 _:2',
        'A5:.75 C#6:.25 F#6:1 E6:.5 C#6:.5 A5:1',
        'G#5:.5 E#5:.5 C#5:1 _:2'
      ],'A final low answer leaves the dominant open and hands the next loop back to the shared call.',{function:'ending',answers:[
        '_:4',
        '_:2 B5:.5 A5:.5 E5:1',
        '_:4',
        '_:2 B4:.5 G#4:.5 E#4:.5 _:0.5'
      ]})
    ]
  },
  'viridia_last_ferry': {
    root:2,scale:'major',groove:'escort',mood:'hopeful',drumVolume:.32,
    leadSound:{attack:.006,decay:.09,sustain:.47,release:.04,pulseWidth:.30,vibratoDepth:.09,cutoff:5000},
    phrases:[
      P('The ferry answers the flare','D A Bm G',[
        'D5:.25 F#5:.25 A5:1 E5:.5 F#5:.5 D5:1 _:0.5',
        'C#5:.5 E5:.5 A5:.75 B5:.25 C#6:1 A5:1',
        'F#5:.5 D5:.5 B4:.5 D5:.5 F#5:1 B5:1',
        'B5:.75 A5:.25 G5:1 D5:.5 G5:.5 B5:1'
      ],'The coastal triadic head becomes a short flare, answered through a new dominant-first route.'),
      P('Escort the first sector','Em A D A',[
        'E5:.5 G5:.5 B5:1 A5:.5 G5:.5 E5:1',
        'A5:.75 E5:.25 C#5:.5 E5:.5 A5:.5 C#6:.5 B5:1',
        'A5:1 F#5:.5 D5:.5 E5:.5 F#5:.5 A5:1',
        'C#6:.5 B5:.5 A5:.75 E5:.25 C#5:1 _:1'
      ],'The answer alternates short intercepts and longer downward reassurance.'),
      P('Fire crosses the wake','Bm Fsm G A',[
        'B5:.25 D6:.25 F#6:.5 E6:.5 D6:.5 B5:1 A5:1',
        'C#6:.75 A5:.25 F#5:.5 A5:.5 C#6:1 E6:1',
        'D6:.5 B5:.5 G5:1 A5:.25 B5:.25 D6:.5 G6:1',
        'E6:.75 C#6:.25 B5:.5 A5:.5 E5:1 C#5:1'
      ],'Rising fragments make the escort urgent, then fall toward the ferry instead of closing.',{density:'busy'}),
      P('Find the sheltered channel','Em G Bm A',[
        'G5:1 E5:.5 B4:.5 E5:1 F#5:1',
        'G5:.5 B5:.5 D6:1 B5:1 A5:1',
        'F#5:.5 D5:.5 B4:1 D5:.5 F#5:.5 B5:1',
        'A5:1 E5:.5 C#5:.5 B4:1 _:1'
      ],'The melody lowers its destination across four bars to make the approaching shelter audible.'),
      P('Under the sea-wall shelter','G D Em A',[
        'B4:1.5 D5:.5 G5:1 _:1',
        'F#5:2 E5:.5 D5:.5 _:1',
        'E5:1 B4:.5 G4:.5 B4:1 _:1',
        'C#5:1 E5:1 A5:.5 _:1.5'
      ],'A lower augmented coastal gesture removes the backbeat and leaves a sheltered breath.',{function:'breakdown',density:'sparse'}),
      P('Lanterns ready to depart','G Bm Em Asus',[
        'D5:1 G5:.5 B5:.5 A5:1 G5:1',
        'F#5:1 D5:.5 B4:.5 D5:1 F#5:1',
        'G5:.5 E5:.5 B5:1 A5:.5 G5:.5 E5:1',
        'D5:1 E5:.5 A5:1.5 _:1'
      ],'A suspended answer raises the ferry out of the respite before the next sector.',{function:'contrast',energy:.82}),
      P('The second sector opens','D G Bm A',[
        'D5:.25 F#5:.25 A5:.5 D6:1 C#6:.5 A5:.5 F#5:1',
        'G5:.75 B5:.25 D6:.5 B5:.5 A5:1 G5:1',
        'B5:.5 F#5:.5 D6:1 B5:.5 A5:.5 F#5:1',
        'E5:.5 A5:.5 C#6:.5 E6:.5 C#6:1 B5:1'
      ],'The flare head now clears a higher destination, and its answer climbs instead of falling.'),
      P('Cover the open water','Em G D A',[
        'B5:.5 G5:.5 E5:.5 G5:.5 B5:1 E6:1',
        'D6:1 B5:.5 G5:.5 D5:.5 G5:.5 B5:1',
        'A5:.5 F#5:.5 D5:1 F#5:.25 A5:.25 D6:.5 F#6:1',
        'E6:.5 C#6:.5 A5:.5 E5:.5 C#5:1 E5:1'
      ],'Alternating cover arcs let the second sector develop independently of the first.',{density:'busy'}),
      P('The far shore is in sight','Bm G Em A',[
        'D6:.5 F#6:.5 E6:.5 D6:.5 B5:1 F#5:1',
        'G5:.25 B5:.25 D6:.5 G6:1 F#6:.5 D6:.5 B5:1',
        'G5:.5 B5:.5 E6:1 D6:.5 B5:.5 G5:1',
        'A5:1 C#6:.5 E6:.5 D6:.5 C#6:.5 A5:1'
      ],'The last rising flare earns one brief high G and then settles into a broader major answer.',{density:'busy'}),
      P('Keep one light on the water','G A D A',[
        'B5:1 G5:.5 D5:.5 G5:.5 A5:.5 B5:1',
        'C#6:.5 A5:.5 E5:1 B5:.5 A5:.5 E5:1',
        'D5:.25 F#5:.25 A5:1 F#5:.5 E5:.5 D5:1 _:0.5',
        'E5:.5 C#5:.5 A4:1 C#5:1 _:1'
      ],'A changed low flare acknowledges the civilian landing while the open dominant preserves the gameplay loop.',{function:'ending'})
    ]
  },
  'aurora_courier': {
    root:4,scale:'dorian',groove:'courier',mood:'dark',drumVolume:.29,
    leadSound:{attack:.003,decay:.055,sustain:.33,release:.028,pulseWidth:.20,vibratoDepth:.035,cutoff:4700},
    phrases:[
      P('Measure the courier signal','Em A Bm Em',[
        'E5:.5 B5:.5 F#5:.5 G5:.5 _:1 C#6:.5 B5:.5',
        'A5:.5 E5:.25 C#5:.25 _:0.5 E5:.5 A5:1 B5:1',
        'F#5:.75 B5:.25 D6:.5 C#6:.5 B5:1 A5:1',
        'G5:1 F#5:.25 E5:.25 _:0.5 B5:1 G5:1'
      ],'Aurora’s isolated fifth is subdivided into a measured targeting cell with a new Dorian endpoint.'),
      P('Compute the crossing','C D Em A',[
        'E5:.25 G5:.25 C6:.5 B5:.5 G5:.5 E5:1 D5:1',
        'F#5:.5 A5:.5 D6:1 A5:.25 F#5:.25 E5:.5 D5:1',
        'E5:.5 G5:.25 B5:.25 _:0.5 E6:.5 D6:.5 B5:.5 G5:1',
        'C#6:.75 B5:.25 A5:.5 E5:.5 F#5:1 E5:1'
      ],'Short launches change interval size and destination as the route crosses separate ice lanes.'),
      P('Pursuit beneath the arches','Em D A B7',[
        'B5:.5 E6:.5 G6:.5 E6:.5 B5:1 A5:1',
        'F#6:.5 D6:.25 A5:.25 F#5:.5 A5:.5 D6:1 E6:1',
        'C#6:.25 E6:.25 A6:.5 E6:1 C#6:.5 B5:.5 A5:1',
        'D#6:.5 B5:.5 F#5:.5 D#5:.5 B4:1 _:1'
      ],'The pursuit opens into longer high arcs and first exposes a functional B dominant.',{density:'busy'}),
      P('The false departure lane','C Bm A Em',[
        'G5:.75 E5:.25 C5:.5 E5:.5 G5:.5 B5:.5 C6:1',
        'B5:.5 F#5:.5 D5:1 F#5:.5 A5:.5 B5:1',
        'C#6:1 A5:.25 E5:.25 _:0.5 F#5:1 E5:1',
        'G5:.5 B5:.5 E6:1 D6:.5 B5:.5 G5:1'
      ],'A low detour rebuilds the targeting cell before it re-enters the courier’s altitude.'),
      P('Observe through the ice','Esus Em A Bm',[
        'A5:1.5 B5:.5 E5:1 _:1',
        'G5:1 F#5:.5 E5:.5 B4:1 _:1',
        'C#5:1 E5:1 A5:.5 _:1.5',
        'F#5:1 D5:.5 B4:.5 F#4:1 _:1'
      ],'The hunter briefly holds its calculation; the prepared fourth releases without erasing the distant signal.',{function:'breakdown',density:'sparse'}),
      P('High intercept window','Em A D B7',[
        'E5:.5 B5:.5 G6:.5 F#6:.5 E6:.5 D6:.5 B5:1',
        'C#6:.25 E6:.25 A6:.5 G6:.5 E6:.5 C#6:1 A5:1',
        'A5:.5 D6:.5 F#6:.75 E6:.25 D6:.5 A5:.5 F#5:1',
        'F#5:.25 B5:.25 D#6:.5 F#6:.5 A6:.5 F#6:1 D#6:1'
      ],'The measured fifth leaps into a changed high landing and is answered by an ascending dominant.',{density:'busy'}),
      P('Drive disabled','C D Em A',[
        'C6:1 B5:.25 G5:.25 E5:.5 G5:.5 C6:.5 E6:1',
        'D6:.5 A5:.5 F#5:1 E5:.5 F#5:.5 A5:1',
        'B5:.75 G5:.25 E5:.5 B4:.5 E5:1 F#5:1',
        'E5:.5 C#5:.5 A4:1 C#5:.5 E5:.5 A5:1'
      ],'Descending targeting fragments lower the line as the courier stops rather than claiming a full victory cadence.'),
      P('Secure the approach codes','A Em C B7',[
        'C#6:1 E6:.5 C#6:.5 B5:1 A5:1',
        'G5:.5 E5:.5 B4:1 E5:.5 G5:.5 B5:1',
        'C6:.5 E6:.5 G6:.75 E6:.25 C6:1 G5:1',
        'F#5:.5 A5:.5 B5:1 D#6:.5 F#6:.5 B6:1'
      ],'A new A-major opening and one high B mark the completed intercept while pressure remains.',{function:'contrast'}),
      P('Signal returns with the codes','Em C A D',[
        'E5:.5 B5:.5 F#5:.25 G5:.25 B5:.5 E6:1 D6:1',
        'C6:.75 G5:.25 E5:.5 G5:.5 B5:1 C6:1',
        'C#6:.5 A5:.25 E5:.25 F#5:.5 E5:.5 C#5:1 A4:1',
        'D5:.5 F#5:.5 A5:1 D6:.5 C#6:.5 A5:1'
      ],'The exact fifth head returns with a shorter continuation, new harmonic route and rising answer.'),
      P('Meridian homeward','C Bm A Em',[
        'E6:.5 C6:.5 G5:1 E5:.5 D5:.5 C5:1',
        'D5:.5 F#5:.5 B5:1 A5:.5 F#5:.5 D5:1',
        'E5:.75 C#5:.25 A4:.5 C#5:.5 E5:1 A5:1',
        'G5:.5 F#5:.5 E5:1 B4:1 _:1'
      ],'A lower modal settling gesture leaves room for the opening measurement to start again.',{function:'ending'})
    ]
  },
  'tempest-flight': {
    root:6,scale:'minor',groove:'lightning',bassCutoff:1350,drumVolume:.36,
    leadSound:{attack:.003,decay:.075,sustain:.46,release:.03,pulseWidth:.16,vibratoDepth:.07,cutoff:5900},
    phrases:[
      P('Lightning cuts the conduit','Fsm D A Cs7',[
        'F#5:.25 A5:.25 C#6:.5 _:0.5 E6:.5 C#6:.5 A5:.5 G#5:1',
        'F#5:.75 A5:.75 D6:.5 C#6:.5 A5:.5 F#5:1',
        'E6:.5 C#6:.5 A5:1 B5:.5 C#6:.5 E6:1',
        'E#6:.5 C#6:.5 B5:.5 G#5:.5 E#5:1 _:1'
      ],'A sixteenth spark and a missing beat establish the storm cut; three-part accents follow.'),
      P('Ride the clear interval','Fsm E D Cs7',[
        'A5:1 C#6:.5 F#6:.5 E6:1 C#6:1',
        'B5:.5 G#5:.5 E5:1 G#5:.5 B5:.5 E6:1',
        'D6:1 A5:.5 F#5:.5 E5:.5 F#5:.5 A5:1',
        'G#5:.25 B5:.25 C#6:.5 E#6:1 D#6:.5 C#6:.5 B5:1'
      ],'The answering line widens into longer arcs and replaces the opening harmonic route.'),
      P('Storm-vane sequence','Bm D Fsm Cs7',[
        'B5:.25 D6:.25 F#6:.5 D6:.5 B5:.5 A5:1 F#5:1',
        'A5:.25 D6:.25 F#6:.5 A6:1 F#6:.5 D6:.5 A5:1',
        'C#6:.5 F#6:.5 A6:.75 G#6:.25 F#6:1 C#6:1',
        'B5:.25 C#6:.25 E#6:.5 G#6:.5 B6:.5 G#6:1 E#6:1'
      ],'Fragmented sparks rise through a new bass route toward a dominant upper seventh.',{density:'busy'}),
      P('Fall behind the lightning front','Fsm E D Cs7',[
        'F#6:1 E6:.5 C#6:.5 A5:1 F#5:1',
        'E5:.5 G#5:.5 B5:.75 A5:.25 G#5:1 E5:1',
        'F#5:.5 A5:.5 D6:1 C#6:.5 A5:.5 F#5:1',
        'E#5:.5 G#5:.5 C#6:1 B5:1 _:1'
      ],'A descending contour mirrors the storm climb and opens a gap before the eye.'),
      P('Eye of the storm','Fsm A D Cs7',[
        'A5:2 C#6:1 _:1',
        'E6:1.5 C#6:.5 A5:1 _:1',
        'F#5:1 A5:.5 D6:1.5 C#6:1',
        'B5:1 G#5:1 E#5:1 _:1'
      ],'Long notes and reduced percussion leave an audible calm between lightning fronts.',{function:'breakdown',density:'sparse'}),
      P('Conduits reconnect','Bm Fsm D Cs7',[
        'F#5:.25 B5:.25 D6:.5 F#6:.5 E6:.5 D6:1 B5:1',
        'C#6:1 A5:.5 F#5:.5 G#5:.5 A5:.5 C#6:1',
        'D6:.75 F#6:.25 A6:1 G#6:.5 F#6:.5 D6:1',
        'C#6:.5 E#6:.5 G#6:.5 F#6:.5 E#6:1 C#6:1'
      ],'Short sparks rebuild the pulse but the continuation stays broader than the opening.',{density:'busy'}),
      P('Light through the cloud deck','A E D Bm',[
        'C#6:1 E6:.5 A6:1 E6:.5 C#6:1',
        'G#6:1 E6:.5 B5:.5 G#5:1 B5:1',
        'A5:1 D6:.5 F#6:.5 E6:1 D6:1',
        'F#6:1 D6:.5 B5:.5 A5:1 F#5:1'
      ],'An A-major clearing removes the dominant and turns the line toward a broad minor landing.',{function:'contrast'}),
      P('Above the final front','D E Fsm Cs7',[
        'A5:.25 D6:.25 F#6:.5 A6:.5 F#6:.5 D6:1 A5:1',
        'B5:.25 E6:.25 G#6:.5 B6:1 G#6:.5 E6:.5 B5:1',
        'A6:.5 F#6:.5 C#6:.5 A5:.5 C#6:.5 F#6:.5 A6:1',
        'G#6:.5 E#6:.5 C#6:.5 B5:.5 G#5:.5 E#5:.5 C#5:1'
      ],'The register peaks at high B, then collapses toward the exposed dominant root.',{density:'busy'}),
      P('Lightning call returns','Fsm D A Cs7',[
        'F#5:.25 A5:.25 C#6:.5 _:0.5 F#6:.5 E6:.5 C#6:.5 A5:1',
        'D6:.75 A5:.75 F#5:.5 A5:.5 C#6:.5 D6:1',
        'C#6:1 E6:.5 A6:.5 G#6:.5 E6:.5 C#6:1',
        'B5:.5 C#6:.5 E#6:1 G#6:1 _:1'
      ],'The spark head returns, but its destination, second-bar direction and dominant ending all change.'),
      P('Bring the squadron home','D Bm Fsm Cs7',[
        'F#6:1 D6:.5 A5:.5 F#5:1 A5:1',
        'B5:.5 D6:.5 F#6:1 E6:.5 D6:.5 B5:1',
        'A5:.75 C#6:.25 F#6:1 E6:.5 C#6:.5 A5:1',
        'G#5:.5 E#5:.5 C#5:1 B4:1 _:1'
      ],'A falling final arc leaves a quiet dominant breath for the next storm cut.',{function:'ending'})
    ]
  },
  'tempest-boss': {
    root:6,scale:'minor',groove:'crown',bassWave:'pulse',bassCutoff:1100,drumVolume:.39,
    leadSound:{attack:.002,decay:.055,sustain:.40,release:.025,pulseWidth:.12,vibratoDepth:.045,cutoff:6100},
    phrases:[
      P('Crown claims the storm','Fsm G Fsm Cs7',[
        'F#5:.25 A5:.25 C#6:.25 F#6:.25 _:0.5 E6:.5 C#6:.5 A5:.5 G#5:1',
        'G5:.5 B5:.5 D6:.75 F#6:.25 D6:1 B5:1',
        'A5:.25 C#6:.25 F#6:.5 E6:.5 C#6:.5 A5:1 F#5:1',
        'E#5:.5 G#5:.5 B5:.5 C#6:.5 E#6:1 _:1'
      ],'The lightning spark becomes a four-note cut, interrupted by a deliberate flat-second front.'),
      P('Fortress storm reply','D Bm Fsm Cs7',[
        'F#6:1 D6:.5 A5:.5 F#5:.5 A5:.5 D6:1',
        'D6:.25 F#6:.25 B6:.5 A6:.5 F#6:.5 D6:1 B5:1',
        'C#6:.5 A5:.5 F#5:.75 A5:.25 C#6:1 F#6:1',
        'G#6:.5 E#6:.5 C#6:1 B5:.5 G#5:.5 E#5:1'
      ],'The answer starts on a held peak and moves through changing registers rather than copying the cut.'),
      P('Strip the storm vanes','Bm D G Cs7',[
        'B5:.25 D6:.25 F#6:.5 B6:1 A6:.5 F#6:.5 D6:1',
        'A5:.25 D6:.25 F#6:.5 A6:.5 F#6:.5 D6:1 A5:1',
        'G5:.25 B5:.25 D6:.5 G6:.5 F#6:.5 D6:1 B5:1',
        'B5:.25 C#6:.25 E#6:.5 G#6:.5 B6:.5 G#6:1 E#6:1'
      ],'A descending series of vane calls meets an ascending dominant counterforce.',{density:'busy'}),
      P('Heart above the clouds','Fsm Fssus Fsm Cs7',[
        'F#5:1 _:1 C#6:1 _:1',
        'B5:2 C#6:1 _:1',
        'A5:1 G#5:.5 F#5:.5 C#5:1 _:1',
        'E#5:1 G#5:1 B5:1 _:1'
      ],'The cut expands into silence and a prepared B-to-A release reveals the fortress heart.',{function:'breakdown',density:'sparse'}),
      P('Crown unleashes the front','D G Fsm Cs7',[
        'D6:.25 F#6:.25 A6:.5 F#6:.5 D6:.5 A5:1 F#5:1',
        'G5:.25 B5:.25 D6:.5 G6:1 F#6:.5 D6:.5 B5:1',
        'F#6:.25 A6:.25 C#7:.5 A6:.5 F#6:.5 E6:.5 C#6:.5 A5:1',
        'G#5:.5 B5:.5 C#6:.5 E#6:.5 G#6:1 B6:1'
      ],'The original spark reaches its only high C-sharp while the flat second forces a new route.',{density:'busy'}),
      P('Storm front closes again','Fsm D G Cs7',[
        'F#5:.25 A5:.25 C#6:.25 F#6:.25 E6:.5 C#6:.5 A5:.5 F#5:.5 E5:1',
        'F#5:.75 A5:.25 D6:1 C#6:.5 A5:.5 F#5:1',
        'G5:.5 D6:.5 B5:1 A5:.5 G5:.5 D5:1',
        'E#5:.5 G#5:.5 C#6:1 B5:1 _:1'
      ],'The four-note cut returns as a falling line, then a flat-second detour redirects the loop dominant.',{function:'ending'})
    ]
  },
  'anchorage-flight': {
    root:7,scale:'major',groove:'orbit',mood:'hopeful',drumVolume:.29,
    leadSound:{attack:.055,decay:.12,sustain:.67,release:.075,pulseWidth:.5,vibratoDepth:.16,vibratoRate:4.5,cutoff:3000},
    phrases:[
      P('Dragonfly beacon','G Em C D',[
        'B5:1.5 D6:1.5 G5:1',
        'B5:1 G5:.5 E5:.5 F#5:1 G5:1',
        'E5:1.5 G5:.5 C6:1 B5:1',
        'A5:1.5 F#5:.5 E5:1 _:1'
      ],'A broad rising third and falling fifth identify the carrier beacon over 3+3+2 phrasing.'),
      P('The wide interception arc','G C Am D',[
        'D6:1 B5:.5 G5:.5 A5:1 B5:1',
        'C6:1.5 B5:.5 G5:1 E5:1',
        'A5:1 E5:.5 C5:.5 E5:1 A5:1',
        'F#5:.5 A5:.5 D6:1 C6:.5 A5:.5 F#5:1'
      ],'An answering curve changes the chord route and ends with an ascending dominant arc.'),
      P('Bombers beyond the ring','Em Bm C D',[
        'B5:.5 G5:.5 E5:1 F#5:.5 G5:.5 B5:1',
        'D6:1 F#6:.5 D6:.5 B5:1 A5:1',
        'G5:1 E5:1 C5:.5 E5:.5 G5:1',
        'A5:.5 D6:.5 F#6:1 E6:.5 D6:.5 A5:1'
      ],'Shorter notes and relative-minor footing turn the broad beacon into a warning.',{function:'contrast',density:'busy'}),
      P('Hold the carrier line','C G Am D',[
        'E6:2 D6:.5 C6:.5 G5:1',
        'D6:1.5 B5:.5 G5:1 _:1',
        'C6:1 B5:.5 A5:.5 E5:1 _:1',
        'F#5:1 A5:1 D6:1 _:1'
      ],'Sustained upper notes give the defensive orbit a stable center.',{function:'breakdown',density:'sparse'}),
      P('Climbing turnaround','G D Em C',[
        'G5:.5 B5:.5 D6:1 G6:1 F#6:1',
        'F#6:1 D6:.5 A5:.5 F#5:.5 A5:.5 D6:1',
        'E6:1 G6:.5 B6:.5 G6:1 E6:1',
        'G6:1 E6:.5 D6:.5 C6:1 G5:1'
      ],'The beacon third expands into a full climbing turnaround before falling back toward the carrier.',{density:'busy'}),
      P('Across the vulnerable side','Am Em C D',[
        'E5:1 C5:.5 A4:.5 C5:1 E5:1',
        'G5:1.5 B5:.5 G5:1 E5:1',
        'C6:1 B5:.5 G5:.5 E5:1 D5:1',
        'A5:1 F#5:.5 D5:.5 E5:.5 F#5:.5 A5:1'
      ],'A low arc and changing phrase endpoints make the patrol feel newly exposed.',{function:'contrast'}),
      P('Beacon in the clear','G Em C Gsus',[
        'B5:1.5 D6:1 G6:.5 D6:.5 B5:.5',
        'E6:1 B5:.5 G5:.5 F#5:1 E5:1',
        'G5:.5 C6:.5 E6:1 D6:1 C6:1',
        'C6:1.5 D6:.5 G5:1 _:1'
      ],'The beacon head returns with an added summit and a suspended, unresolved answer.'),
      P('Keep the circle open','C Am G D',[
        'E6:1 D6:.5 C6:.5 G5:1 E5:1',
        'A5:1 C6:.5 B5:.5 A5:1 E5:1',
        'G5:1 B5:.5 D6:.5 B5:1 A5:.5 G5:.5',
        'F#5:1 A5:.5 D6:.5 A5:1 _:1'
      ],'An open dominant rises toward the beacon B rather than stopping on a full cadence.',{function:'ending'})
    ]
  },
  'anchorage-boss': {
    root:4,scale:'minor',groove:'harrow',bassCutoff:1250,drumVolume:.35,
    leadSound:{attack:.009,decay:.09,sustain:.50,release:.04,pulseWidth:.22,vibratoDepth:.10,cutoff:4700},
    phrases:[
      P('Harrow inverts the beacon','Em C Am B7',[
        '_:0.5 B5:.75 G5:.75 E5:1 B4:1',
        'G5:.5 E5:.5 C6:1 B5:.5 G5:.5 _:1',
        '_:0.5 E5:.5 A5:.75 C6:.25 B5:1 A5:1',
        'F#5:.5 D#5:.5 B4:1 A5:1 _:1'
      ],'The beacon third turns downward, starts off the beat and falls through the carrier harmony.'),
      P('Hunter crosses the wake','Em G C B7',[
        'G5:.5 B5:.5 E6:1 D6:.5 B5:.5 G5:1',
        '_:0.5 D6:.5 B5:.5 G5:.5 A5:.5 B5:.5 D6:1',
        'E6:.75 G6:.25 E6:1 C6:.5 B5:.5 G5:1',
        'F#6:1 D#6:.5 B5:.5 A5:.5 F#5:.5 D#5:1'
      ],'The reply trades a downbeat climb for an offbeat answer and a long falling dominant.'),
      P('Narrowing defense ring','Am C Em B7',[
        'C6:.5 E6:.5 A6:1 G6:.5 E6:.5 C6:1',
        'G6:.5 E6:.5 C6:.5 G5:.5 E5:1 G5:1',
        'B5:.25 E6:.25 G6:.5 E6:.5 D6:.5 B5:.5 G5:.5 E5:1',
        'D#5:.5 F#5:.5 B5:.5 D#6:.5 F#6:1 A6:1'
      ],'The broad orbit contracts into a compressed falling cell while the dominant climbs.',{density:'busy'}),
      P('Dragonfly exposed','C Em Am B7',[
        'E5:1.5 G5:.5 C6:1 _:1',
        'B5:1 G5:1 E5:1 _:1',
        'A4:1 C5:.5 E5:.5 A5:1 _:1',
        'F#5:1 D#5:.5 B4:.5 A4:1 _:1'
      ],'The wide original breathing briefly returns in a lower, vulnerable register.',{function:'breakdown',density:'sparse'}),
      P('Intercept from above','G C Am B7',[
        'B5:.75 D6:.75 G6:.5 D6:.5 B5:.5 G5:1',
        'C6:.5 E6:.5 G6:1 E6:.5 D6:.5 C6:1',
        '_:0.5 E6:.5 C6:.5 A5:.5 B5:.5 C6:.5 E6:1',
        'F#6:.5 D#6:.5 B5:1 D#6:.5 F#6:.5 A6:1'
      ],'The carrier beacon fights back in a shorter high-register arc before the hunter dominant.',{density:'busy'}),
      P('Blind arc reopens','Em C Am B7',[
        '_:0.5 B5:.75 G5:.75 E6:1 D6:1',
        'C6:1 G5:.5 E5:.5 G5:1 B5:1',
        'A5:.5 E5:.5 C5:1 E5:.5 A5:.5 C6:1',
        'B5:.5 A5:.5 F#5:1 D#5:1 _:1'
      ],'The initial inversion now leaps upward before its changed descent resets the pursuit.',{function:'ending'})
    ]
  },
  'cinder-flight': {
    root:9,scale:'dorian',groove:'treads',bassWave:'pulse',bassCutoff:900,drumVolume:.38,
    leadSound:{attack:.004,decay:.08,sustain:.38,release:.035,pulseWidth:.38,vibratoDepth:.065,cutoff:4200},
    phrases:[
      P('Jackal tread riff','Am Am D E7',[
        'A4:.75 C5:.25 E5:.5 _:0.5 D#5:.25 E5:.75 A4:1',
        'C5:.5 E5:.5 A5:.75 G5:.25 E5:1 _:1',
        'D5:.75 F#5:.25 A5:.5 F#5:.5 E5:1 D5:1',
        'B4:.5 D5:.5 G#5:.75 E5:.25 D5:1 _:1'
      ],'A low blues pickup and semitone approach lock onto the tank backbeat.'),
      P('Convoy answer','Am C D E7',[
        'A4:.5 E5:.5 G5:.5 A5:.5 E5:1 C5:1',
        'G5:.75 E5:.25 C5:.5 E5:.5 G5:.5 C6:.5 G5:1',
        'F#5:1 A5:.5 D6:.5 A5:.5 F#5:.5 D5:1',
        'E5:.75 G#5:.25 B5:1 D6:.5 B5:.5 G#5:1'
      ],'The answer begins on the bass pickup and redirects the riff into a brighter Dorian route.'),
      P('Jets over the causeway','F G Am E7',[
        'A5:.5 C6:.5 F6:1 E6:.5 C6:.5 A5:1',
        'B5:.5 D6:.5 G6:.75 F6:.25 D6:1 B5:1',
        'A5:1 E6:.5 C6:.5 B5:.5 A5:.5 E5:1',
        'G#5:.5 B5:.5 E6:.5 D6:.5 B5:1 G#5:1'
      ],'Wide leaps crest above the low riff for the jet-assisted jump.',{density:'busy'}),
      P('Foundry rollers','Am G D E7',[
        'A4:.5 C5:.25 D5:.25 E5:.5 G5:.5 A5:1 E5:1',
        'D5:.75 G5:.25 B5:.5 G5:.5 D5:.5 B4:.5 G4:1',
        'A4:.5 D5:.5 F#5:1 E5:.5 D5:.5 A4:1',
        'B4:.5 E5:.5 G#5:1 B5:.5 G#5:.5 E5:1'
      ],'The riff fragments through changing bass roots and alternates rising and falling machinery.'),
      P('Empty broken span','F Am D E7',[
        'C5:2 A4:1 _:1',
        'E5:1 C5:1 A4:1 _:1',
        'F#5:1 E5:.5 D5:.5 A4:1 _:1',
        'G#4:1 B4:1 D5:1 _:1'
      ],'The tread rhythm drops out, leaving low notes and open space over the causeway.',{function:'breakdown',density:'sparse'}),
      P('Furnace mouths','Dm F Am E7',[
        'F5:.75 A5:.25 D6:.5 C6:.5 A5:1 F5:1',
        'C6:.5 A5:.5 F5:.5 A5:.5 C6:1 F6:1',
        'E6:.5 C6:.5 A5:.5 G5:.5 E5:.25 D#5:.25 E5:.5 A5:1',
        'B5:.75 G#5:.25 E5:.5 D5:.5 B4:1 E5:1'
      ],'Minor subdominant heat replaces the Dorian lift and the chromatic pickup returns in descent.',{function:'contrast'}),
      P('Jackal finds a lane','C G D Am',[
        'E5:.5 G5:.5 C6:.75 B5:.25 G5:1 E5:1',
        'D5:.5 G5:.5 B5:1 A5:.5 G5:.5 D5:1',
        'F#5:1 A5:.5 D6:.5 E6:1 D6:1',
        'C6:.5 A5:.5 G5:.5 E5:.5 C5:1 A4:1'
      ],'A major-side opening becomes a Dorian climb, then settles in the original low register.'),
      P('Steel under fire','F D Am E7',[
        'A5:.25 C6:.25 F6:.5 C6:.5 A5:.5 F5:1 A5:1',
        'A5:.25 D6:.25 F#6:.5 E6:.5 D6:.5 A5:1 F#5:1',
        'A5:.5 C6:.5 E6:.75 G6:.25 E6:.5 C6:.5 A5:1',
        'G#5:.5 B5:.5 D6:.5 E6:.5 G#6:1 E6:1'
      ],'Short anacruses climb to the strongest dominant color of the mission.',{density:'busy'}),
      P('Treads catch again','Am C D E7',[
        'A4:.75 C5:.25 E5:.5 A5:.5 G5:.5 E5:.5 C5:1',
        'E5:.5 G5:.5 C6:1 B5:.5 G5:.5 E5:1',
        'D5:.75 F#5:.25 A5:.5 D6:.5 C#6:.5 A5:.5 F#5:1',
        'E5:1 B5:.5 G#5:.5 D5:1 B4:1'
      ],'The recognizable tread head gets a new upper answer, then falls beneath the convoy.'),
      P('Toward the siege line','F D Am E7',[
        'C6:.5 A5:.5 F5:1 E5:.5 F5:.5 A5:1',
        'F#5:.5 A5:.5 D6:1 A5:1 F#5:1',
        'E5:.75 C5:.25 A4:1 C5:.5 D#5:.25 E5:.25 C5:1',
        'B4:.5 D5:.5 G#4:1 E4:1 _:1'
      ],'A shorter blues gesture drops to E, leaving room for the riff pickup at the loop.',{function:'ending'})
    ]
  },
  'cinder-boss': {
    root:9,scale:'minor',groove:'maw',bassWave:'pulse',bassCutoff:820,drumVolume:.40,
    leadSound:{attack:.005,decay:.13,sustain:.48,release:.035,pulseWidth:.47,vibratoDepth:.04,cutoff:3600},
    phrases:[
      P('Iron Maw footprint','Am Bb Am E7',[
        'A4:1.5 C5:.5 E5:1 _:1',
        'Bb4:.75 F5:.25 D5:1 Bb5:.5 A5:.5 F5:1',
        'A4:.5 C5:.5 E5:.75 D#5:.25 E5:1 A5:1',
        'G#5:1 E5:.5 D5:.5 B4:1 _:1'
      ],'The tread riff is augmented and interrupted by a flat-second footprint.'),
      P('Crushing counterstroke','Dm Bb Am E7',[
        'F5:1 A5:.5 D6:.5 C6:1 A5:1',
        'F6:.75 D6:.25 Bb5:.5 F5:.5 D5:1 Bb4:1',
        'C5:.75 E5:.25 A5:1 G5:.5 E5:.5 C5:1',
        'B4:.5 D5:.5 E5:1 G#5:.5 B5:.5 D6:1'
      ],'The answer alternates high and low weight, then climbs on the dominant seventh.'),
      P('Piston tower','F Dm Bb E7',[
        'F5:.5 A5:.5 C6:1 F6:.5 E6:.5 C6:1',
        'D6:.5 F6:.5 A6:1 G6:.5 F6:.5 D6:1',
        'D6:.5 F6:.5 Bb6:1 A6:.5 F6:.5 D6:1',
        'D6:.25 E6:.25 G#6:.5 E6:.5 D6:.5 B5:1 G#5:1'
      ],'A rising piston sequence increases register without reusing the original riff rhythm.',{density:'busy'}),
      P('Broken crawler armor','Am Bb Dm E7',[
        'A4:2 _:1 E5:1',
        'F5:1 D5:1 Bb4:1 _:1',
        'A4:1 D5:1 F5:1 _:1',
        'G#4:1 B4:.5 D5:.5 E5:1 _:1'
      ],'Low sustained roots and separated replies expose the machinery between attacks.',{function:'breakdown',density:'sparse'}),
      P('Siege retaliation','Am Dm Bb E7',[
        'A4:.75 C5:.25 E5:.5 A5:.5 C6:1 E6:1',
        'F6:.5 D6:.5 A5:.5 F5:.5 A5:.5 D6:.5 F6:1',
        'Bb6:.5 F6:.5 D6:1 C6:.5 Bb5:.5 F5:1',
        'E5:.5 G#5:.5 B5:.5 D6:.5 E6:1 G#6:1'
      ],'The tread returns as a climbing attack while the flat-second reply falls across the line.',{density:'busy'}),
      P('Tracks close the circle','F Bb Am E7',[
        'A5:1 C6:.5 F6:.5 E6:.5 C6:.5 A5:1',
        'Bb5:.75 F5:.25 D5:.5 F5:.5 Bb5:1 A5:1',
        'E5:.5 C5:.5 A4:1 D#5:.25 E5:.75 C5:1',
        'D5:.5 B4:.5 G#4:1 E4:1 _:1'
      ],'The original chromatic pickup now falls into the low dominant before the crawler advances again.',{function:'ending'})
    ]
  },
  'terminus-flight': {
    root:0,scale:'minor',groove:'trench',bassCutoff:1550,drumVolume:.37,
    leadSound:{attack:.006,decay:.10,sustain:.62,release:.04,pulseWidth:.32,vibratoDepth:.08,cutoff:5400},
    phrases:[
      P('Command on an open channel','Cm Ab Eb G7',[
        'C5:.75 G5:.25 Eb5:1 Bb5:1 G5:1',
        'Ab5:1 Eb6:.5 C6:.5 Ab5:1 _:1',
        'G5:.75 Bb5:.25 Eb6:1 D6:1 Bb5:1',
        'B5:1 D6:1 G5:1 _:1'
      ],'A clipped command pickup meets weighty quarter-note answers.'),
      P('The squadron answers','Cm Fm Bb G7',[
        'Eb5:1 G5:.5 C6:.5 G5:1 Eb5:1',
        'F5:.75 Ab5:.25 C6:1 Eb6:.5 C6:.5 Ab5:1',
        'F5:1 Bb5:.5 D6:.5 F6:1 D6:1',
        'D6:.5 B5:.5 G5:1 F5:.5 D5:.5 B4:1'
      ],'The answer changes the harmonic route and sends the command below its starting register.'),
      P('Shipyard gantries','Ab Eb Fm G7',[
        'C6:.5 Eb6:.5 Ab6:1 G6:.5 Eb6:.5 C6:1',
        'Bb5:.5 G5:.5 Eb5:1 G5:.5 Bb5:.5 Eb6:1',
        'C6:.5 Ab5:.5 F5:1 Ab5:.5 C6:.5 F6:1',
        'F6:.5 D6:.5 B5:.5 G5:.5 D6:1 B5:1'
      ],'Alternating downward and upward spans trace the gantries without copying the command period.',{density:'busy'}),
      P('Drop into the trench','Cm Bb Ab G7',[
        'G5:1 Eb5:1 C5:.5 G4:.5 C5:1',
        'D5:1 F5:.5 Bb5:.5 A5:1 F5:1',
        'Eb5:1 C5:.5 Ab4:.5 C5:1 Eb5:1',
        'D5:.5 F5:.5 G5:1 B5:1 _:1'
      ],'A low falling route narrows the space before an upward dominant signal.'),
      P('Hold your breath','Fm Cm Ab G7',[
        'Ab5:2 G5:.5 F5:.5 _:1',
        'Eb5:1 G5:1 C6:1 _:1',
        'C6:1.5 Ab5:.5 Eb5:1 _:1',
        'B4:1 D5:1 F5:1 _:1'
      ],'Long notes and low dominant support create a clearing inside the driving approach.',{function:'breakdown',density:'sparse'}),
      P('Weapon emplacements','Cm Fm Bbdim G7',[
        'C5:.5 Eb5:.5 G5:.5 C6:.5 Eb6:1 D6:1',
        'C6:.5 Ab5:.5 F5:.5 Ab5:.5 C6:1 F6:1',
        'E6:.5 G6:.5 Bb6:1 G6:.5 E6:.5 Bb5:1',
        'B5:.25 D6:.25 F6:.5 D6:.5 B5:.5 G5:1 F5:1'
      ],'The command fragments into escalating thirds; diminished pressure has a directed dominant release.',{density:'busy'}),
      P('Asterion behind us','Eb Bb Ab G7',[
        'G5:1 Bb5:.5 Eb6:1.5 G6:1',
        'F6:1 D6:.5 Bb5:.5 F5:1 Bb5:1',
        'C6:1 Eb6:.5 C6:.5 Ab5:1 G5:1',
        'F5:.5 G5:.5 B5:1 D6:1 _:1'
      ],'A major-side refuge broadens the melody before the carrier blocks the route.',{function:'contrast'}),
      P('Last light in the trench','Fm Ab Cm G7',[
        'F6:1 Eb6:.5 C6:.5 Ab5:1 F5:1',
        'Ab5:.75 C6:.25 Eb6:1 G6:.5 Eb6:.5 C6:1',
        'G5:.5 C6:.5 Eb6:.5 G6:.5 C7:1 Bb6:1',
        'B6:.5 G6:.5 F6:.5 D6:.5 B5:1 G5:1'
      ],'A long rising chain saves the octave C for the approach climax.',{density:'busy'}),
      P('Command returns changed','Cm Ab Fm G7',[
        'C5:.75 G5:.25 Eb5:.5 G5:.5 C6:1 Eb6:1',
        'Eb6:1 C6:.5 Ab5:.5 G5:1 Eb5:1',
        'F5:.75 Ab5:.25 C6:.5 F6:.5 Eb6:1 C6:1',
        'D6:1 B5:.5 G5:.5 D5:1 F5:1'
      ],'The command pickup is recognizable; its answer now rises and the cadence changes roots.'),
      P('Commit to the core','Ab Bb Cm G7',[
        'C6:1 Ab5:.5 Eb5:.5 Ab5:1 C6:1',
        'D6:.5 F6:.5 D6:.5 Bb5:.5 F5:1 D5:1',
        'Eb5:1 G5:.5 C6:.5 Bb5:1 G5:1',
        'F5:.5 D5:.5 B4:1 G4:1 _:1'
      ],'A falling unclosed G dominant points back into the command pickup.',{function:'ending'})
    ]
  },
  'terminus-boss': {
    root:0,scale:'minor',groove:'sovereign',bassWave:'pulse',bassCutoff:950,drumVolume:.39,
    leadSound:{attack:.003,decay:.075,sustain:.56,release:.03,pulseWidth:.21,vibratoDepth:.04,cutoff:5200},
    phrases:[
      P('Sovereign fires','Cm Ab Fm G7',[
        'C5:.25 G5:.25 Eb5:.5 _:1 Bb5:.5 G5:.5 Eb5:1',
        'Ab5:.5 C6:.5 Eb6:1 C6:.5 Ab5:.5 _:1',
        'F5:.5 C6:.5 Ab5:1 F6:.5 Eb6:.5 C6:1',
        'B5:.5 D6:.5 F6:1 D6:.5 B5:.5 _:1'
      ],'The command pickup becomes a clipped low attack and the answer loses its safe major refuge.'),
      P('Carrier armor','Cm Bb Ab G7',[
        'Eb6:1 C6:.5 G5:.5 C6:.5 Eb6:.5 G6:1',
        'F6:.5 D6:.5 Bb5:.5 F5:.5 D5:1 Bb4:1',
        'C5:.5 Eb5:.5 Ab5:1 C6:.5 Eb6:.5 Ab6:1',
        'G6:.5 F6:.5 D6:.5 B5:.5 G5:1 F5:1'
      ],'Broad armor phrases alternate whole-register descent and ascent.'),
      P('Jump-drive charge','Fm Bbdim Cm G7',[
        'F5:.25 Ab5:.25 C6:.5 F6:1 Eb6:.5 C6:.5 Ab5:1',
        'E5:.25 G5:.25 Bb5:.5 E6:.5 G6:.5 Bb6:1 G6:1',
        'G6:.5 Eb6:.5 C6:.5 G5:.5 C6:.5 Eb6:.5 G6:1',
        'B6:.5 G6:.5 F6:.5 D6:.5 B5:.5 G5:.5 F5:1'
      ],'Diminished thirds compress the march while a high leading tone points toward the core.',{density:'busy'}),
      P('The command core is exposed','Cm Csus Cm G7',[
        'C5:1 G5:1 _:1 Eb5:1',
        'F5:2 G5:1 _:1',
        'Eb5:1 D5:.5 C5:.5 G4:1 _:1',
        'B4:1 D5:.5 F5:.5 G5:1 _:1'
      ],'A bare low command and prepared fourth-to-third resolution reveal the core.',{function:'breakdown',density:'sparse'}),
      P('All weapons converge','Ab Fm Cm G7',[
        'Eb6:.5 Ab6:.5 G6:.5 Eb6:.5 C6:1 Ab5:1',
        'C6:.5 F6:.5 Ab6:1 G6:.5 F6:.5 C6:1',
        'Eb6:.25 G6:.25 C7:.5 Bb6:.5 G6:.5 Eb6:.5 C6:.5 G5:1',
        'F5:.5 G5:.5 B5:.5 D6:.5 F6:1 G6:1'
      ],'The mission summit is re-earned through a compressed high command and contrary bass route.',{density:'busy'}),
      P('Threshold pressure','Cm Fm Ab G7',[
        'C5:.25 G5:.25 Eb5:.5 G5:.5 C6:.5 Eb6:1 D6:1',
        'C6:1 Ab5:.5 F5:.5 Ab5:.5 C6:.5 F6:1',
        'Eb6:.5 C6:.5 Ab5:1 G5:.5 Eb5:.5 C5:1',
        'D5:.5 F5:.5 B5:1 G5:1 _:1'
      ],'The opening head returns with a changed climb, then descends into the loop dominant.',{function:'ending'})
    ]
  },
  'aurora-flight': {
    root:4,scale:'dorian',groove:'ice',mood:'peaceful',answerVoice:'chipTom',drumVolume:.26,
    leadSound:{attack:.035,decay:.18,sustain:.56,release:.065,pulseWidth:.5,vibratoDepth:.19,vibratoRate:4.1,cutoff:3500},
    phrases:[
      P('A signal in the ice','Em A Em D',[
        'E5:1.5 _:1 B5:.5 A5:.5 F#5:.5',
        'E5:1 C#5:1 _:1 E5:1',
        'G5:1.5 F#5:.5 E5:1 _:1',
        'F#5:2 A5:.5 F#5:.5 E5:.5 _:0.5'
      ],'An isolated fifth leap is answered by a Dorian sixth and a falling third.',{answers:['_:4','_:2.5 A4:.5 E5:1','_:3 B4:.5 _:0.5','_:4']}),
      P('Crystal answer','C D Em A',[
        'G5:1 E5:.5 D5:.5 E5:1 _:1',
        'A5:1.5 F#5:.5 E5:.5 D5:.5 _:1',
        'B5:1 G5:.5 E5:.5 F#5:1 G5:1',
        'A5:1 C#6:.5 B5:.5 E5:1 _:1'
      ],'The answer fills the original silence and reaches the Dorian color above the line.'),
      P('Through blue fractures','Em G D A',[
        'B5:2 A5:.5 G5:.5 E5:1',
        'D6:1 B5:.5 G5:.5 A5:1 B5:1',
        'A5:1 F#5:1 E5:1 D5:1',
        'C#5:1 E5:.5 A5:1.5 _:1'
      ],'The signal is rhythmically broadened, then moves down through a full register.',{function:'contrast'}),
      P('Suspended corridor','Esus Em A Bm',[
        'A5:1.5 B5:.5 A5:1 _:1',
        'G5:2 F#5:.5 E5:.5 _:1',
        'E5:1 C#5:1 B4:.5 C#5:.5 E5:1',
        'F#5:1 D5:.5 B4:1.5 _:1'
      ],'Prepared A falls to G while accompaniment clears its third; the cadence remains remote.',{function:'breakdown',density:'sparse',answers:['_:4','_:3 B4:.5 _:0.5','_:4','_:3 F#4:.5 _:0.5']}),
      P('Relay refractions','C A D Em',[
        'E5:.5 G5:.5 C6:1 B5:.5 G5:.5 E5:1',
        'C#6:1 E6:.5 C#6:.5 A5:1 E5:1',
        'F#5:.5 A5:.5 D6:1 C#6:.5 A5:.5 F#5:1',
        'E6:1 B5:.5 G5:.5 F#5:1 E5:1'
      ],'Related rising cells gain different continuations and a new high E.',{density:'busy'}),
      P('The moon remembers','Em Bm A D',[
        'G5:1.5 E5:.5 B4:1 _:1',
        'D5:1 F#5:.5 B5:1.5 A5:1',
        'E5:1 C#5:.5 E5:.5 A5:1 B5:.5 C#6:.5',
        'D6:2 A5:1 _:1'
      ],'The same signal now rises from below and opens into a major arrival.',{function:'contrast'}),
      P('Distant signal return','Em A C D',[
        'E5:1.5 _:0.5 B5:.5 D6:.5 B5:.5 A5:.5',
        'C#6:1 A5:.5 E5:.5 F#5:1 E5:1',
        'G5:1 E5:.5 G5:.5 C6:1 B5:1',
        'A5:.5 F#5:.5 D5:1 F#5:.5 A5:.5 D6:1'
      ],'The signal head returns with a shorter gap, a new upper turn and an ascending answer.'),
      P('Under the relay lights','C Bm A Em',[
        'C6:1 B5:.5 G5:.5 E5:1 D5:1',
        'F#5:1 D5:1 B4:1 _:1',
        'C#5:1 E5:.5 A5:.5 E5:1 F#5:1',
        'G5:1 B5:.5 A5:.5 F#5:1 E5:.5 _:0.5'
      ],'A modal settling gesture leaves half a beat before the original isolated E.',{function:'ending',answers:['_:4','_:3 F#4:.5 _:0.5','_:4','_:4']})
    ]
  },
  'aurora-boss': {
    root:4,scale:'minor',groove:'rime',bassCutoff:1000,
    leadSound:{attack:.003,decay:.045,sustain:.27,release:.025,pulseWidth:.125,vibratoDepth:.02,cutoff:6400},
    phrases:[
      P('RIME acquires the signal','Em A Em B7',[
        'E5:.5 _:0.5 B5:.25 A5:.25 F#5:.5 E5:.5 B5:.5 _:1',
        'C#6:.5 A5:.25 E5:.25 _:0.5 A5:.5 B5:.5 C#6:.5 E6:1',
        'B5:.25 A5:.25 G5:.5 E5:1 _:0.5 F#5:.5 G5:.5 B5:.5',
        'D#6:.5 F#6:.5 B5:1 A5:.5 F#5:.5 _:1'
      ],'The long-distance signal loses its sustain and becomes clipped tracking bursts.'),
      P('Hunter arms answer','C D Em B7',[
        'G5:.75 E5:.25 G5:.5 C6:.5 E6:.5 D6:.5 C6:1',
        'A5:.25 D6:.25 F#6:.5 D6:1 A5:.5 F#5:.5 E5:1',
        'G5:1 B5:.5 E6:.5 D6:.5 B5:.5 G5:1',
        'F#5:.5 D#5:.5 B4:1 _:0.5 D#5:.5 F#5:1'
      ],'The reply changes the attack positions and drives toward a lower leading tone.'),
      P('Frost breach','F Em C B7',[
        'F5:.5 A5:.5 C6:.5 B5:.5 A5:1 F5:1',
        'E5:.25 F5:.25 E5:.5 G5:.5 B5:.5 E6:1 D6:1',
        'C6:.5 E6:.5 G6:1 E6:.5 D6:.5 C6:1',
        'B5:.25 C6:.25 D#6:.5 F#6:.5 A6:.5 F#6:1 D#6:1'
      ],'F-natural interrupts the Dorian memory and resolves into E before the dominant peak.',{density:'busy'}),
      P('Cold central eye','Em Esus Em B7',[
        'E5:1 _:1 B5:1 _:1',
        'A5:1.5 B5:.5 E5:1 _:1',
        'G5:1 F#5:.5 E5:.5 B4:1 _:1',
        'D#5:1 F#5:1 A5:1 _:1'
      ],'A stripped signal reveals its original spacing but alters the suspended answer.',{function:'breakdown',density:'sparse'}),
      P('Pursuit vectors','A C Em B7',[
        'C#6:.25 E6:.25 A6:.5 E6:1 C#6:.5 B5:.5 A5:1',
        'G5:.5 C6:.5 E6:.5 G6:.5 E6:.5 D6:.5 C6:1',
        'E6:.5 B5:.25 G5:.25 E5:.5 G5:.5 B5:1 D6:1',
        'D#6:.75 F#6:.75 A6:.5 F#6:.5 D#6:.5 B5:1'
      ],'The fleeting Dorian sixth now initiates a registral chase through different chord shapes.',{density:'busy'}),
      P('The hunter re-locks','Em C F B7',[
        'E5:.5 B5:.25 A5:.25 G5:.5 E6:1 D6:.5 B5:1',
        'C6:1 G5:.5 E5:.5 G5:.5 C6:.5 E6:1',
        'F6:.5 C6:.5 A5:1 G5:.5 F5:.5 E5:1',
        'F#5:.5 A5:.5 D#6:1 B5:1 _:1'
      ],'A changed signal head falls through the intrusive F harmony before resetting on B.',{function:'ending'})
    ]
  },
  'viridia-flight': {
    root:2,scale:'major',groove:'coast',mood:'hopeful',
    leadSound:{attack:.008,decay:.11,sustain:.58,release:.045,pulseWidth:.25,vibratoDepth:.10,cutoff:6200},
    phrases:[
      P('Sea-wall call','D G Bm A',[
        'D5:.5 F#5:1 A5:1.5 F#5:.5 E5:.5',
        'G5:1 B5:.5 A5:.5 G5:1 _:1',
        'F#5:.5 B5:1 D6:1 B5:.5 A5:1',
        'C#6:1 B5:.5 A5:1.5 _:1'
      ],'Triadic lift reaches a dominant answer; the final rest leaves the next launch clear.'),
      P('Evacuation answer','D G Em A',[
        'F#5:1 A5:.5 D6:1 A5:.5 F#5:1',
        'B5:.5 A5:.5 G5:1 D6:1 B5:1',
        'G5:1 F#5:.5 E5:.5 B5:1 G5:.5 E5:.5',
        'E5:.5 F#5:.5 E5:.5 C#5:.5 A4:1 _:1'
      ],'The answering descent closes lower than the call and changes its final rhythm.'),
      P('Above the sea wall','D Fsm G A',[
        'D5:.5 F#5:.5 A5:.5 D6:1.5 C#6:.5 A5:.5',
        'C#6:1 A5:1 F#5:.5 A5:.5 C#6:1',
        'D6:1 B5:.5 G5:.5 A5:.5 B5:.5 D6:1',
        'E6:1 C#6:.5 B5:.5 A5:1 _:1'
      ],'The opening cell fragments upward and reaches the first high E.',{density:'busy'}),
      P('Corridor opens','Dsus D Bm A',[
        'D6:1.5 A5:.5 G5:1 A5:1',
        'F#5:2 E5:.5 F#5:.5 A5:1',
        'B5:1 A5:.5 F#5:.5 D5:1 F#5:1',
        'E5:1 C#5:1 B4:.5 C#5:.5 E5:1'
      ],'Longer suspension and stepwise release relax the preceding ascent.'),
      P('City in shadow','Bm G Em Fsm',[
        'B4:1 F#5:.5 D5:1.5 _:1',
        'D5:1 G5:1 F#5:.5 E5:.5 D5:1',
        'B4:.5 E5:1 G5:1 F#5:.5 E5:1',
        'C#5:1 F#5:1 A5:1 _:1'
      ],'Relative-minor register drop and wider rests make space for the burning city.',{function:'contrast',density:'sparse'}),
      P('Turning toward the line','Em A D Bm',[
        'E5:.5 G5:.5 B5:1 G5:.5 E5:.5 F#5:1',
        'A5:.5 C#6:.5 B5:.5 A5:.5 E5:1 C#5:1',
        'F#5:1 A5:1 D6:.5 C#6:.5 A5:1',
        'B5:1 D6:.5 F#6:1 D6:.5 B5:1'
      ],'The bass route leaves the minor center and the line earns a new F-sharp summit.',{density:'busy'}),
      P('Rooftop crossings','G D Em A',[
        'D6:1 B5:1 G5:.5 A5:.5 B5:1',
        'A5:.5 F#5:.5 E5:.5 D5:.5 A5:1 F#5:1',
        'G5:.5 B5:.5 E6:1 D6:.5 B5:.5 G5:1',
        'A5:1 E6:.5 C#6:.5 B5:1 A5:1'
      ],'Contrary registral motion turns repeated climbs into alternating rooftop arcs.'),
      P('Break through the fire','Bm Fsm G A',[
        'F#5:.5 B5:.5 D6:.5 B5:.5 F#5:.5 D5:.5 B4:1',
        'C#5:.5 F#5:.5 A5:.5 C#6:.5 A5:1 F#5:1',
        'B5:.5 D6:1 G6:.5 D6:1 B5:1',
        'E6:.5 C#6:.5 A5:1 B5:.5 C#6:.5 E6:1'
      ],'The melodic sequence changes direction each bar and saves the highest G for the breach.',{density:'busy'}),
      P('Saltlight return','D G Bm Asus',[
        'D5:.5 F#5:1 A5:1 D6:.5 C#6:.5 A5:.5',
        'G5:1 B5:.5 D6:.5 B5:1 A5:1',
        'B5:.5 F#5:.5 D6:1 C#6:.5 B5:.5 F#5:1',
        'D6:1 E6:.5 D6:.5 A5:1 _:1'
      ],'The original head returns with a higher continuation and a suspended answer.'),
      P('Course back to the coast','G A D A',[
        'B5:1 A5:.5 G5:.5 D5:1 G5:1',
        'C#6:.5 B5:.5 A5:1 E5:1 C#5:1',
        'D5:1 F#5:.5 A5:.5 F#5:1 E5:.5 D5:.5',
        'E5:1 C#5:1 A4:1 _:1'
      ],'An unclosed dominant leaves a clear breath and points back to the opening D.',{function:'ending'})
    ]
  },
  'viridia-boss': {
    root:2,scale:'minor',groove:'blockade',bassWave:'pulse',bassCutoff:1050,
    leadSound:{attack:.004,decay:.08,sustain:.48,release:.035,pulseWidth:.18,vibratoDepth:.06,cutoff:5800},
    phrases:[
      P('Warden intercept','Dm Gm Bb A7',[
        'D5:.25 F5:.25 A5:.5 _:1 A5:.5 F5:.5 E5:.5 D5:.5',
        'G5:.75 D5:.75 Bb5:.5 A5:.5 G5:.5 _:1',
        'F5:.5 Bb5:.5 D6:1 F6:.5 D6:.5 Bb5:1',
        'C#6:.75 E6:.75 C#6:.5 A5:1 _:1'
      ],'The coastal triad compresses into a minor attack and displaced rests.'),
      P('Broadside answer','Dm Bb Gm A7',[
        'F5:1 A5:.25 D6:.25 A5:.5 F5:1 D5:1',
        'D6:.5 Bb5:1 F5:.5 Bb5:1 A5:1',
        'Bb5:.5 G5:.5 D6:.75 Bb5:.75 G5:.5 _:1',
        'E6:.5 C#6:.5 A5:.5 G5:.5 E5:1 C#5:1'
      ],'The answer sustains the first beat, reverses the arpeggiated route and lands on the leading tone.'),
      P('Blockade closes','Gm Dm Bb A7',[
        'G5:.5 Bb5:.5 D6:.5 G6:.5 D6:1 Bb5:1',
        'A5:.75 F5:.75 D5:.5 F5:.5 A5:.5 D6:1',
        'F6:.5 D6:.5 Bb5:.5 A5:.5 Bb5:1 D6:1',
        'C#6:.25 D6:.25 E6:.5 C#6:.5 A5:.5 G5:.5 E5:.5 C#5:1'
      ],'Sequence rises across changing bass roots; the final bar tightens into the dominant.',{density:'busy'}),
      P('Under the gun deck','Dm Dm Gm A7',[
        'D5:2 _:1 F5:1',
        'A5:1 F5:1 E5:.5 D5:.5 _:1',
        'Bb4:1 D5:.5 G5:.5 D5:1 _:1',
        'C#5:1 E5:1 G5:1 _:1'
      ],'A low, exposed version of the call clears space before the final assault.',{function:'breakdown',density:'sparse'}),
      P('Attack the command bridge','Bb Gm Dm A7',[
        'D6:.5 F6:.5 D6:1 Bb5:.5 A5:.5 F5:1',
        'G5:.25 Bb5:.25 D6:.5 G6:1 F6:.5 D6:.5 Bb5:1',
        'A5:.5 D6:.5 F6:1 E6:.5 D6:.5 A5:1',
        'G5:.5 A5:.5 C#6:.5 E6:.5 G6:1 E6:1'
      ],'The triad now starts above the original range and climbs to the dominant seventh.',{density:'busy'}),
      P('Frigate turns to fire','Dm Bb Gm A7',[
        'D6:.25 F6:.25 A6:.5 F6:1 D6:.5 A5:.5 F5:1',
        'Bb5:.75 D6:.75 F6:.5 D6:.5 Bb5:.5 A5:1',
        'G5:.5 D6:1 Bb5:.5 G5:1 D5:1',
        'E5:.5 G5:.5 A5:1 C#6:1 _:1'
      ],'A shortened falling return retains the coastal identity while the dominant resets combat.',{function:'ending'})
    ]
  },
};
