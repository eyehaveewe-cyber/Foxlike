# Foxlike design and handoff

Version 1.0 · 22 October 2026 · Director: Jonathan Sanders

The original version-1.0 design below is preserved. Its three-stage scope and pending checks are historical. The current implementation is summarized here; dated verification belongs in [VERIFICATION.md](VERIFICATION.md).

## Current implementation and plan status

Audit baseline: `39b5aa7202a9216fc2504f983665e535e6afec5f`, October 30, 2026. The current game has six campaign missions, five companions, twelve original MBean1 mission/boss tracks, peaceful exploration of twelve planets and 93 moons, and the separate Phase One practice duel. These are implemented features. The longer eight-phase campaign plan describes additional work; the existing short campaign does not satisfy that expanded plan by sharing mission names.

| Documented work | Current implementation | Evidence or remaining dependency |
| --- | --- | --- |
| Six-mission campaign, combat, companions and tank support | Implemented | Campaign, squadron, combat, expansion and tank-support suites. |
| Original music for each level and boss | Implemented | Twelve editable MBean1 projects, decoded OGG reports and 114 native audio checks. |
| Planet grid, reachable moons and peaceful flight | Implemented | 40 orbit checks and 70 orbit-exploration checks. |
| Phase One shared flight, cover, opponent and review tools | Technical practice implementation is present | 38 duel regressions, arranged capture and source-stamped trace. Human acceptance is pending. |
| Phase Two expanded carrier operation and independent companion flight | Proposed expansion, not a completed phase | Requires the selected Phase One flight/camera configuration and its acceptance evidence. The existing Anchorage mission is the earlier compact defense arena. |
| Phases Three through Seven expanded missions and campaign continuity | Proposed expansion, not completed phases | Consume Phase Two's objective/companion contracts and later mission, checkpoint, rival and recovery contracts. The planning documents do not constitute implementation evidence. |
| Phase Eight whole-campaign acceptance | Pending | Requires the expanded campaign, human journeys, agreed physical devices and Windows target measurements. Current export and browser checks establish only the compact build's recorded results. |

The full Phase One guide requires a human Standard win, an explainable human loss, cover-driven sight loss, a high-attack counter and a blocked approach, repeated with reduced camera motion. It also requires choosing between the two arena volumes and pitch behaviors. Those observations and the production choice have not been supplied. The practice foundation remains available for that review; no automatic test can select the preferred feel or stand in for a human encounter.

The Phase Two guide's entry requirements consume that selected configuration. Later phase guides also contain unresolved director choices and physical acceptance requirements. Until those inputs exist, the later rollout is pending. This audit does not select a provisional default as an approved production choice, implement the later campaign under an unreviewed profile, or mark any human gate passed.

Current starting instructions are in [RUNNING.md](RUNNING.md). The [Phase One implementation and open gates](PHASE_01_IMPLEMENTATION.md) identify the review setup and trace location. [VERIFICATION.md](VERIFICATION.md) records the October 30 native, audio and browser results. The original Phase One DOCX stays authoritative for its completion criteria.

Foxlike is a compact 3D arcade flight campaign built for a complete first playthrough: launch from a carrier, fight across three routes, defeat their bosses, and reach a campaign ending. Responsive movement and visible ship animation are the main priorities. This record preserves the brief, the implementation choices and the next work for the project.

## Phase One practice implementation update — 23 October 2026

The current authorized work follows the complete supplied *Foxlike Phase 1 A fair flight duel* v1.0 and the director's eight-phase scope clarification. The new Anchorage practice operation implements a shared nose-directed controller, observed opponent, solid cover, world projectiles, two volume experiments, pitch/camera options and local evidence capture. The existing campaign is retained as the current baseline; Phase Two will integrate the reviewed flight foundation into Anchorage's complete operation. Human Standard acceptance and production configuration selection are pending. The detailed ownership, provisional numbers, evidence and open gates are in [PHASE_01_IMPLEMENTATION.md](PHASE_01_IMPLEMENTATION.md). The original design record below remains historical.

## Direction and authorship

| ID | Source and status | Direction |
| --- | --- | --- |
| H1 | Human request; authorized | Build the best one-shot full Starfox-like game, then continue development later. |
| H2 | Human request; authorized | Project Barrel Roll code, themes and models may be used. Foxlike is a separate repository. |
| H3 | Human priority; authorized | Make animation and the presentation of flight a central demonstration. |
| A1 | AI-authored implementation choice | Use Godot 4.7.2, a three-stage on-rails campaign, procedural models and original synthesized audio. |
| A2 | AI-authored implementation choice | Use Comet Flight in the Asterion setting with named wingmen and multipart bosses. |

H1 through H3 come from the request on 22 October 2026. A1 and A2 are choices made within that broad build authorization; their exact details were not separately selected by the director. Implementation is in progress at this document revision. A passing test and approval of a design are separate facts.

## Intended experience

The player is Mara Venn, callsign COMET, leading LATCH and GLINT from the Dragonfly carrier. A close chase camera keeps banking, rolling, recoil, engine thrust and formation movement visible. The player steers within a moving flight corridor, reads enemy approaches and alternates precise shooting with defensive maneuvers.

The first release is single player and contains a beginning, middle and ending. Free-roaming all-range flight, multiplayer, a branching campaign and a large equipment economy remain outside this build. The aim is a coherent first game with room for later expansion, rather than a claim of final commercial polish.

## Campaign and combat

Routes introduce the flight verbs before combining them. Each route ends at a dedicated boss. The durations below are authored route time; launches, boss fights, results and player decisions add to the full run.

| Stage | Route time | Encounter purpose |
| --- | --- | --- |
| Viridia | 88 seconds | Reopen a coastal evacuation corridor. Formation attacks and recovery rings lead to WARDEN, the blockade frigate. |
| Aurora | 96 seconds | Follow the relay signal through ice and debris. Tighter steering and target selection lead to RIME and its articulated weapon arms. |
| Terminus | 104 seconds | Cross an orbital shipyard and attack SOVEREIGN. Combine defensive flight and subsystem targeting to reach the command core. |

### Core rules

| System | First implementation rule |
| --- | --- |
| Lasers and lock | Hold fire for repeated laser shots. Keeping aim on a target builds a lock; R or right mouse fires a homing missile with a 2.5-second recharge. |
| Roll and speed | Q and E trigger a 0.68-second roll with defensive invulnerability and a 1.15-second cooldown. Shift boosts using energy; Ctrl brakes. |
| Limited attacks | B spends one of three nova bombs. F calls wingman assistance, then waits 24 seconds before another call. |
| Recovery | Collect rings to restore the shield and develop laser strength. Rings reward deliberate movement through the corridor. |
| Progress | Scores, medals and unlocked missions persist. A failed stage can be retried. Records support replay after the campaign ending. |

These values are AI-authored starting balance, not measured difficulty targets. The first playtest should establish whether incoming shots, collision hazards and boss attacks give enough warning at the real flight speed. Preserve rapid response when adjusting animation timings.

### A representative decision

An approaching formation offers a lock opportunity while a dangerous lane forces lateral movement. The player can finish the lock and spend the missile, roll through the attack, or break aim and collect a recovery ring. A failed dodge should cost readable shield damage and leave a clear route back into control. The roll animation must never conceal the next required decision.

Escape pauses. M toggles sound, C toggles wingman chatter, and F11 toggles fullscreen. Keyboard, mouse and controller behavior must be checked in the final integration pass; available bindings alone do not establish good control feel.

## Implementation structure

Godot owns the scene and rendering. The main flight controller owns movement, combat state and damage. Visual rigs animate below their root nodes so cosmetic motion cannot silently change gameplay authority. Forward is negative Z; scenery advances toward the camera.

| File | Responsibility |
| --- | --- |
| flight_game.gd | Campaign state, input, flight, waves, projectiles, pickups, bosses, score and persistence. |
| ship_model.gd | Procedural Arrow airframes, enemies, Dragonfly carrier and articulated boss rigs. Exposes visual weak points. |
| flight_world.gd | Stage lighting and scenery. Seven reusable chunks of 160 units provide bounded scenery generation. Decorative geometry does not own gameplay collision. |
| flight_hud.gd and flight_overlay.gd | Menus, briefing, flight indicators, messages, result screens and targeting graphics. |
| flight_effects.gd | Combat particles, flashes, trails and other short-lived visual effects. |
| flight_audio.gd and assets/audio | Six looping mission and boss arrangements, twelve sound effects, volume and mute, capped playback voices. |

### Lifecycle and continuity

The state sequence is menu, briefing, launch, route, boss, clear animation and result. Death and retry return to a defined stage entry. Stage transitions must clear expired actors, targeting references and effects. Pause should freeze combat consistently while preserving working menu controls.

The save file is user://foxlike_save.json. It records campaign access, score records, sound preference and difficulty. Save loading is an external-data boundary: clamp unlocked stages, reject malformed records and keep a playable default. Mid-flight checkpoint recovery is not part of this version.

### Assets and animation

Ship shapes and environment geometry are generated in code. The procedural work follows Project Barrel Roll motifs: swept wings, visible cyan canopy and engines, a segmented insect-like carrier and articulated RIME mechanisms. The original tactical presentation supplies visual references; the real-time controller uses its own timing and combat rules.

The soundtrack and effects are original synthesis. Six 32-bar arrangements run approximately 50 to 60 seconds before looping; separate boss versions increase rhythmic intensity. The generation source is assets/audio/generate_audio.py and requires NumPy plus ffmpeg. Runtime playback uses Ogg music and short PCM effects, with twelve effect voices and a laser sound rate limit.

## Verification and next work

The current phase is first implementation and integration. Gameplay validation belongs in the final repository verification report, with the exact tested revision. This design record does not count code inspection as a completed campaign playtest.

| Area | Evidence or next acceptance check |
| --- | --- |
| Audio verified | Godot 4.7.2 parsed and instantiated the audio component. All six looping tracks, twelve effects, mute, gain and stop behavior passed a runtime smoke. PCM analysis found no clipped samples. This is not a subjective listening review. |
| Campaign pending | Complete every route and boss through the ending. Also test death, retry, next mission, replay and returning to the menu. |
| Controls pending | Test keyboard, mouse and gamepad independently. Check quick direction changes, roll recovery, pause, focus loss and resized windows. |
| Presentation pending | Inspect all stages and bosses in rendered play. Check wingmen, attack warnings, hit feedback and weak-point visibility from the gameplay camera. |
| Persistence pending | Reload after each unlock and result. Verify malformed saves cannot block launching a fresh run. |
| Performance pending | Measure rendered frame time and actor/resource counts over repeated stages. Check the intended older-PC and browser targets before claiming support. |

### Recommended next priorities

First, fix any obstacle to finishing a run and tune targeting or incoming attacks that feel unclear. Then refine animation transitions and boss reactions against recorded play. Once the controls and pacing hold up, consider branching routes or an all-range encounter. Those expansions are proposals for a later direction decision; they are not commitments in this build.

Coverage includes flight, combat, a short campaign, audiovisual presentation, basic results and persistence. Content breadth, accessibility options, localization, distribution packaging and long-session balance need further review. Multiplayer and a tactical layer are deferred. No system has been rejected permanently.

### Sources and revision history

Version 1.0 records the 22 October 2026 user brief, the inspected Project Barrel Roll sources and the Foxlike implementation handoff. H1 through H3 retain human origin. Campaign specifics, numerical balance and new content retain AI origin. There are no superseded design decisions in this first record.

- [Foxlike repository](https://github.com/eyehaveewe-cyber/Foxlike)

- [Project Barrel Roll carrier source](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/carrier-deployment/scripts/carrier_hull.gd)

- [Project Barrel Roll fighter source](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/carrier-deployment/scripts/fighter.gd)

- [Project Barrel Roll RIME source](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/rime-tentacle-profiles/scripts/spider_boss.gd)
