# Foxlike campaign score

Sixteen original editable MBean1 projects cover the ten-operation campaign: the original six mission themes and six related boss cues, plus four further operation themes. The original twelve scores and Ogg files retain their recorded hashes. The melodies, rhythms, harmonic routes and phrase continuations are written in concert-pitch notation in [phrases.cjs](phrases.cjs). No notes were copied from Bone Lantern or another existing score. The compiler does not generate or randomize the foreground music.

| Mission | Mission theme | Loop | Boss cue | Loop |
| --- | --- | ---: | --- | ---: |
| Viridia | Saltlight Squadron | 40 bars, 128 BPM, 75.000 s | Warden of the Burning Coast | 24 bars, 144 BPM, 40.000 s |
| Aurora | Signals Beneath the Ice | 32 bars, 96 BPM, 80.000 s | RIME Wakes | 24 bars, 148 BPM, 38.919 s |
| Terminus | One Approach to Sovereign | 40 bars, 132 BPM, 72.727 s | Sovereign at Jump Threshold | 24 bars, 152 BPM, 37.895 s |
| Cinder | Jackal over the Foundry | 40 bars, 120 BPM, 80.000 s | Iron Maw Advances | 24 bars, 132 BPM, 43.636 s |
| Anchorage | Circle of the Dragonfly | 32 bars, 104 BPM, 73.846 s | Harrow in the Blind Arc | 24 bars, 140 BPM, 41.143 s |
| Tempest | Calm Between Lightning Fronts | 40 bars, 136 BPM, 70.588 s | Crown above the Storm | 24 bars, 156 BPM, 36.923 s |

| Further operation | Cue | Playback slot | Loop |
| --- | --- | ---: | ---: |
| `viridia_last_ferry` | The Last Ferry Still Has a Light | 12 | 40 bars, 136 BPM, 70.588 s |
| `aurora_courier` | Intercept at the Blue Meridian | 13 | 40 bars, 132 BPM, 72.727 s |
| `terminus_falling_yard` | Keep the Falling Yard Alive | 14 | 40 bars, 116 BPM, 82.759 s |
| `tempest_stormbreak` | A Forecast We Can Share | 15 | 40 bars, 128 BPM, 75.000 s |

## Musical decisions

Viridia uses a D-major triadic lift, syncopated coastal bass and a lower B-minor city section. Its return retains the opening pickup but changes the upper turn and suspended answer. Warden compresses the coastal triad into D minor, displaces the attacks into 3+3+2 and interrupts the assault with a bare gun-deck section.

Aurora separates its E-Dorian signal with silence, long notes and occasional pitched-tom answers. The suspended corridor prepares A before its release to G. RIME clips the signal into tracking bursts, exposes the Dorian sixth briefly and introduces an F-natural breach with a clear return to E. This cue uses the thinnest, shortest pulse attacks in the set.

Terminus puts a clipped command pickup beside strong quarter notes. Gantry leaps, a low trench passage, a held-breath section and an E-flat refuge all change the approach before the widened final charge. Sovereign breaks the command into shorter attacks, removes the major refuge and uses a diminished approach to the jump-drive peak. C7 appears once in each cue, as a short climax rather than a sustained layer.

Cinder centers the tank on a low A-minor blues pickup, a brief D-sharp approach to E and a grounded backbeat. D-major harmony lifts the jet jumps; D minor colors the furnace section. Iron Maw doubles the tread gesture's opening length, places B-flat against the A-minor home and climbs through piston-like upper replies. The bass is a filtered pulse, so the low foundation has a different edge from the flight stages.

Anchorage uses broad beacon phrases over a relaxed pulse, with melodic 3+3+2 arcs rather than Tempest's short storm cuts. Its climbing turnaround reaches a single high B before returning to the vulnerable lower side of the carrier. Harrow inverts the beacon's opening third, enters off the beat and recasts the defense in E minor. A later high beacon reply gives the carrier theme a recognizably different role.

Tempest alternates a sixteenth-note spark, displaced cuts and long calm passages. Its middle eye removes most percussion; an A-major clearing precedes the last storm climb. Crown extends the spark into a four-note attack, adds a G-major flat-second front and opens a prepared B-to-A release when the heart is exposed. The sole C-sharp7 at boss bar 19 is shorter than a fifth of a second.

Last Ferry turns the coastal lift into a short flare and uses a different dominant-first harmonic route. The first sector lowers its register toward shelter; bars 17–24 remove or soften the backbeat before the second sector answers with a higher flare and changed cover arcs. A low final call acknowledges the civilian crossing without closing the gameplay loop.

Courier subdivides Aurora's long-distance fifth into a measured targeting cell. Its quicker rhythm and selective sixteenth pickups serve precise pursuit rather than RIME's aggressive broken attacks. A quiet observation span precedes the high intercept; the disabled-drive phrase descends into the lower register before a new A-major code-recovery opening. The returning signal changes its continuation and harmonic route.

Falling Yard augments the Terminus command into a low, measured stabilization gesture. Open load-balancing phrases and two quiet spans hold the emergency steady. At bar 21, a diminished rupture breaks the pickup and replaces the support rhythm with driving escape patterns. The final command returns through a changed upward answer before descending to the exit register.

Stormbreak gives the storm spark a broader call and a separate authored answering voice. The two flights occupy one another's rests rather than sustaining bright unisons. F-sharp Dorian introduces a natural sixth and B-major forecast clearings; brief borrowed minor-weather passages precede safe corridors. The recovery passage starts low, then the flights exchange independent climbs. Its return changes both the call's destination and the answer's register.

## Source and reproduction

Run from the Foxlike repository root:

```sh
node assets/audio/mbean/campaign/author_campaign.cjs
```

[manifest.json](manifest.json) is the runtime/rendering inventory. Each `file` is an editable version-4 MusicModel project; the adjacent Ogg name is its cue ID plus `.ogg`. [phrase-map.json](phrase-map.json) lists every four-bar thought, the actual written notes, its harmonic route, its function and the intended audible change. Every phrase also appears as an editable arrangement section and lead clip in its project.

The four further cues use explicit `operation_id` values and `playback_index` values 12–15. They have no numeric `stage` destination, preserving the original six-world stage/boss mapping without duplication.

The compiler starts with `MusicModel.defaultProject`, creates tracks and notes through the pinned model, then runs `MusicModel.validate` on every completed score. Stable IDs and authored note data make regeneration byte-for-byte deterministic. [score-audit.json](score-audit.json) records source/model/output hashes, event counts, phrase signatures, lead ranges, high-pulse durations and the sounding-overlap review.

The only voices are `pulseLead`, `chipBass`, `chipDrums` and Aurora's `chipTom` answers. They use the existing local synth renderer, with distinct pulse widths, attack/decay/sustain, cutoff and vibrato per scene. No sampled assets, downloads or new sample-license obligations are introduced. The upper harmonic shells are quiet, filtered and separate from the bass; they stop at MIDI 74 or 75. Bass and percussion may repeat underneath the developing foreground.

The current MBean1-Astra [README](https://github.com/eyehaveewe-cyber/MBean1/blob/MBean1-Astra/README.md), [model](https://github.com/eyehaveewe-cyber/MBean1/blob/MBean1-Astra/model.js), [chip renderer](https://github.com/eyehaveewe-cyber/MBean1/blob/MBean1-Astra/chip-audio.js), [audio renderer](https://github.com/eyehaveewe-cyber/MBean1/blob/MBean1-Astra/audio.js) and [composition plan](https://github.com/eyehaveewe-cyber/MBean1/blob/MBean1-Astra/docs/composition-design-plan.md) were read through the connected GitHub tools on October 30, 2026. Output targets Foxlike's existing renderer imported from MBean1 commit `ecd441fe`, preserving its schema and supported voices. This work does not change the upstream MBean1 application.

## Review and limits

All 16 projects pass the actual pinned MusicModel validator. All 132 four-bar phrase signatures are distinct within their cues, including rhythm and relative pitch contour. The ten-phrase and eight-phrase mission forms move through contrast and development before changed returns; no cue fills its length with an unchanged foreground period. Each boss transforms the corresponding mission cell through rhythm, harmony, contour and phrase destination. The four added cues contain 40 newly authored thoughts, not retimed or transposed copies of existing project lines.

The note review includes the lead, harmonic shells, answering voices and their supported synth release tails. No exposed semitone or compound minor-ninth between lead and harmonic support lasts a quarter second. One 0.214-second exposure remains in Tempest mission bar 24: F-sharp6 passes above E-sharp4 on a weak eighth, then resolves to E-sharp6. No added cue has a candidate exposure of at least 0.17 seconds. The intentional flat-second chord changes in RIME, Iron Maw and Crown remain intact.

High pulse notes at MIDI 91 and above last at most half a second. Their velocities taper by 12 percent above MIDI 88 and 20 percent at MIDI 94 and above. This softens their attacks while preserving the written climax contours. No high unison accompaniment doubles these peaks.

Every `arrangement.endTick` equals `bars * 1920`. Pitched note gates include release clearance, and the final beat has no new drum hits so fixed noise/kick tails finish before the seam. Endings point to their cue's opening harmony or use a brief modal breath.

`render_campaign.cjs` reuses a prior cue only when its renderer, score and encoded-audio SHA-256 hashes match. It preserves the shipped common gain while rendering additions, and `--force` explicitly rebuilds all audio. The final report contains all sixteen cues, with source/output hashes, decoded levels, durations, silence measurements and loop seam deltas. `validate_campaign.cjs --audio` verifies all sixteen actual Ogg streams and rejects repeated melodies even when their key and tempo change.

These findings come from event, form, renderer inspection and decoded-audio measurements. Audio rendering, decoder checks and runtime playback verification are recorded in [asset provenance](../../../../docs/ASSET_IMPORTS.md) and [verification results](../../../../docs/VERIFICATION.md). Runtime integration of the four further operation cues remains with the parent task. Critical listening on a physical device and the final music-to-effects balance remain human review tasks.
