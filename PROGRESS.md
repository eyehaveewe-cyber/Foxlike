# Foxlike progress

Newest entries first. Historical timestamps were recovered from the linked Git commits and converted to UTC; they do not imply undocumented event times. Descriptions and validation limits are preserved.

## 2026-10-30 09:13:27 UTC — Complete component orders and rival cover roles

Timestamp source: recorded UTC clock time for this integration update.

Unified live aircraft, courier Drive, walker parts, capital components and core marks for the target picker, companion orders and specialist/player missiles. Blocked orders retain their mark and route around cover; lost marks regroup with feedback. Protect follows required friendly cargo. The flight HUD retains companion health, task, named target and cooldown, with readable aircraft labels. Guard abilities require a reachable interception and use actual flight/body collision before cooldown starts. Healthy Stormbreak rivals receive explicit attack and cover roles; damage and withdrawal interrupt the setup within the existing observation and firing rules.

All 53 new command checks pass, including real subsystem missile impacts, physical guard interception, blocked/invalid launches, unavailable companions, persistent HUD state and rival-role changes. The full release run passes 824 native checks across 13 suites, with 14 exported-browser checks. Four normal/large-text native views were inspected. The handoff and reproduction lists include these contracts and checks. Human feel, listening, physical-controller and Windows-device validation remain unmeasured; they do not block this implementation. No music assets changed in this pass; the sixteen original MBean1 cues remain integrated.

## 2026-10-30 08:50:53 UTC — Complete UTC progress history and prevent regressions

Timestamp source: recorded UTC clock time for this documentation update.

Replaced the eight remaining date-only headings and the undated Cinder heading with verified UTC commit timestamps. Moved Cinder to its chronological position and promoted the misplaced orbital momentum and light-lance updates into separate dated entries. All fifteen historical timestamps match linked Git commits after timezone conversion; all original history body text is preserved.

The [documentation checker](tools/check_documentation.py) now rejects missing or invalid UTC timestamps, entries outside newest-first order and malformed source-commit references. CI and source packaging already call this checker. Five negative fixtures were rejected, and a new clock-recorded entry can pass without requiring a future commit hash. Documentation and diff checks pass. No gameplay code changed; the earlier 771 native and fourteen browser checks remain the recorded gameplay evidence.

## 2026-10-30 08:40:42 UTC — Checkpoint validation and completed delivery

Source commit: [f9e5432](https://github.com/eyehaveewe-cyber/Foxlike/commit/f9e5432272af9b09b4512ddcec4c6c9a4c5224aa)

[Commit f9e5432](https://github.com/eyehaveewe-cyber/Foxlike/commit/f9e5432272af9b09b4512ddcec4c6c9a4c5224aa) rejects malformed nested checkpoint data before changing live actors. Validation covers pending arrivals, tank state, motion fields, required carrier/settings fields and actor-ID frontiers. An invalid checkpoint now visibly explains its safe return to the operation briefing. Valid campaign checkpoints retain their prior behavior.

Verification passes **771 native checks across twelve suites** and **fourteen exported-browser checks**. The sequential journey still passes every operation boundary, cold checkpoint/result reload and idempotent settlement. All sixteen MBean1 scores and decoded loops pass validation. Windows, Web and editable-source packages are built; the final source ZIP matches the current files and imports and launches from a fresh extraction. [CI run 41028068763](https://github.com/eyehaveewe-cyber/Foxlike/actions/runs/41028068763) passed. Site publishing was skipped.

The ten-operation programming pass and updated six-page DOCX handoff are delivered. Human feel/balance, listening, physical-controller operation and target Windows hardware performance remain unmeasured validation, not programming gates. Original Phase Two–Eight DOCX transfers were denied by the environment's download policy (HTTP CONNECT 403); their extracted-text snapshots and original Library links are included. See the [implementation map](docs/EXPANDED_CAMPAIGN.md) and [verification record](docs/VERIFICATION.md).

## 2026-10-30 08:31:11 UTC — Expanded campaign programming and completion checks

Source commit: [0f91b63](https://github.com/eyehaveewe-cyber/Foxlike/commit/0f91b630b29f04c3e7a77f027f2dcc561cefd6f4)

Implemented the ten-operation plan under Jonathan’s instruction to disregard human-check prerequisites for programming. The normal flight deck uses shared spatial flight, independent companions, stable mission IDs and checkpoint/save settlement. Added ferry continuity, courier drive interception, functional capital targets, finite encounters, Cinder walker/hover routes, carrier repair, emergency vessel boundaries, Stormbreak controls, Crown escape/recovery and outcome text. Keyboard/controller button rebinding, safe pause/rearm and independent camera/UI options are exposed.

Four new original MBean1 mission cues extend the unchanged original twelve to sixteen tracks. The supplied phase guides are preserved as extracted text with original Library links. A bounded recovery-pose adapter passes 90 checks in the pinned actual PBR lab; its existing 366-check suite also passes. No PBR merge or site publication.

[Implementation and source-plan mapping](docs/EXPANDED_CAMPAIGN.md), [controls](docs/RUNNING.md), and [dated verification](docs/VERIFICATION.md) supersede the earlier audit’s programming gate. Human feel, listening, physical controller and target-PC measurements remain unclaimed validation.

## 2026-10-30 06:34:33 UTC — Documentation implementation audit

Source commit: [6570a7c](https://github.com/eyehaveewe-cyber/Foxlike/commit/6570a7cf65cbc0f72f2fbcde2b5a1a953a5eeeec)

Compared the current build with the preserved handoff, full Phase One guide and later phase plans. The six-mission game, peaceful exploration, soundtrack and technical practice foundation are implemented. The expanded campaign remains proposed work. Phase One still needs the human Standard win, explainable loss, counterplay observations and arena/pitch choice that Phase Two consumes. The [current design status](docs/DESIGN.md#current-implementation-and-plan-status) keeps that dependency visible.

Corrected stale native-suite counts, browser status and MBean1 descriptions. Added `tools/check_documentation.py` to derive native-suite lists from the release packager and check every local Markdown link. CI and source packaging run the check. The source ZIP now includes linked handoffs, evidence and previews, including the previously omitted original design DOCX and paired duel trace. Text reads use UTF-8 and archive/resource paths use forward slashes for portability.

Verification: the checker rejects both broken links and stale suite lists. The complete archive passes CRC and documentation-inclusion checks. A fresh unpacked copy passes documentation checks, imports in Godot 4.7.2 and launches the main scene without script or parse failures. Existing exit resource-cleanup warnings remain. Gameplay code is unchanged, so the earlier 467 native and thirteen browser results remain dated evidence rather than a new full test claim. Later-phase implementation is pending the required human review and configuration decision.

## 2026-10-30 01:07:17 UTC — Original music for every campaign level

Source commit: [39b5aa7](https://github.com/eyehaveewe-cyber/Foxlike/commit/39b5aa7202a9216fc2504f983665e535e6afec5f)

Composed twelve original MBean1 cues using Sol 6.1 with extra-high reasoning as Jonathan requested. Each of the six missions has its own flight theme and related boss cue. The set contains 92 authored four-bar phrases and 9,706 events, with 70.6–80-second mission loops and 36.9–43.6-second boss loops. Changed answers, contrasting sections and developed returns give the cues different identities. Brief high pulse peaks have softer attacks. Existing scores, renders, effects and peaceful-orbit ambience remain preserved.

Included editable MBean1 projects, concert-pitch phrase source, a deterministic compiler, phrase maps, composition review and render evidence under `assets/audio/mbean/campaign/`. All fifteen score JSON artifacts regenerate byte-identically. The unchanged pinned MBean1 Web Audio engine renders the complete cues locally with synthesized voices. A waveform-cache comparison produces identical PCM. Decoded OGG checks cover source hashes, duration, levels, silence and loop boundaries.

The audio controller selects twelve distinct streams and crossfades changes over 0.65 seconds. Repeated requests preserve playback position; rapid changes keep the louder outgoing voice; mute, volume and stop affect both players. Measured music levels informed a 6 dB gain increase relative to the old controller. Added native decoder and real mission-event checks, plus exported-browser audio telemetry and mute checks. See [music provenance and reproduction](docs/ASSET_IMPORTS.md) and [validation](docs/VERIFICATION.md).

Godot 4.7.2 passes all 467 checks across nine native suites, including 114 music checks and the 353 existing regressions. Windows and Web release packages export successfully. The exported Web build passes thirteen real Chromium checks, including soundtrack playback, advancing audio position and mute, with no JavaScript or engine-console errors. The existing native rapid-teardown resource warnings remain. Human critical listening, physical-device mix review and Windows hardware playback are not claimed. No site publishing action was requested or performed.

## 2026-10-25 22:20:18 UTC — Cinder tank air support

Source commit: [0374ec6](https://github.com/eyehaveewe-cyber/Foxlike/commit/0374ec6574cfbab07e2318824a9580d93269fee1)

Tank-mission companions now make staggered five-second strafing passes from opposite screen edges, then withdraw before returning. They fire their real lasers and offensive specialist abilities during the attack window. Bodyguard interception is disabled during ground support; off-screen aircraft cannot intercept projectiles. Normal flight formations are unchanged. Pass timers reset on mission refit/retry.

Inspected Project Barrel Roll `codex/two-legged-ground-walker`: Bastion Assault (`assault_tank`) and Bulwark Fortress (`bulwark`) are armored aircraft chassis with tank roles, not tracked ground tanks. Its actual ground assets include the articulated two-leg walker (`scenes/ground_walker_preview.tscn`, documented in `docs/GROUND_WALKER.md`) and the RIME ground boss. These assets were located, not imported in this change; Cinder retains Foxlike’s existing Jackal tank.

Validation: eight new tank-support checks and 159 existing campaign/squadron/expansion checks pass in Godot 4.7.2. Rendering, physical controller play and a human tank-mission playtest were not performed for this change.

## 2026-10-25 04:58:27 UTC — Asterion orbit selection and reachable moons

Source commit: [ed76cb0](https://github.com/eyehaveewe-cyber/Foxlike/commit/ed76cb0aed49b59384bc42358962b07457fdcc4c)

Reused Project Barrel Roll's complete twelve-world catalog, animated planetary thumbnails and original route chart. Planet Orbits now opens a four-column selection grid with every world available outside campaign unlock rules. Every sector contains its selected 3D planet and full catalogued moon population: 93 moons total across the catalog. Distinct procedural surfaces, atmosphere/cloud configurations and the three source-ringed planets replace the single Viridia backdrop. Each station's identity follows the selected world.

Expanded the local flight radius from 1.8 km to 100 km. Added moon/station waypoint cycling, face-waypoint assistance and a manual travel drive up to 1,500 m/s, with powered approach braking. Moon transfers are continuous navigation, with swept sphere collision and proximity protection. Engine-off momentum, hover and the light lance continue working; asteroids spawn around distant players, and planet swaps clear old visitors/tethers and refit at the new berth.

Distant worlds/moons swap among three shared sphere resolutions and cheaper surface detail. Cloud/atmosphere shells and station details cull with distance/apparent size. Only the selected planet sector is instantiated; the selector is paused and hidden chart animation stops. No target-machine performance claim is made.

Validation: all 345 checks pass across seven suites. New checks cover every world/card/moon/ring, the reused chart, all 93 unique satellite IDs, safe world swaps and continuous moon travel. The Viridia transfer test reached less than 300 m from the first moon in 13.72 simulated seconds at a peak of 795.89 m/s, without crossing a celestial surface. A 1,500 m/s engine-off approach was stopped by the physical moon. Native grid/chart/planet/moon views and a continuous scripted transfer were captured and inspected; Windows/Web exports and editable source packaging succeed. Browser runtime, physical controller and human flight feel remain unverified. See [orbit details](docs/ORBIT_EXPLORATION.md) and [verification](docs/VERIFICATION.md). Phase One's human duel completion gate remains open.

## 2026-10-25 04:14:01 UTC — Orbital light lance

Source commit: [95fcd2c](https://github.com/eyehaveewe-cyber/Foxlike/commit/95fcd2ccc9b3f4e07d32b1fe02cbf0bdd7fc1bb0)

Aim the ship nose at a visible asteroid within 700 m. Press **G / left mouse / controller A** to latch it, then press again to fling. The glowing tether reels the real asteroid toward a stand-off point using a damped spring. Hold for two seconds to charge the fantasy launch from 120 to 320 m/s; ship velocity and part of the asteroid swing velocity carry into the throw. **R** drops the tether without a launch impulse. Solid station cover blocks acquisition and breaks tethers. Returning home, disabling visitors or losing the target releases it safely. The lance works with engines off. Rocks retain ordinary gravity, collisions and momentum after release; the station remains indestructible.

## 2026-10-25 03:28:38 UTC — Orbital hub momentum update

Source commit: [972586f](https://github.com/eyehaveewe-cyber/Foxlike/commit/972586f72f4a080ce133dbbab1e0ecfb6000cd34)

Press **I** or use the options menu to cut/restart the engines. Cutoff disables thrust, hover damping and powered braking; attitude control remains available, and existing velocity survives turns and boost release. Restart engines before using Space to brake. H still toggles powered hover assistance. The outer-room safety arrest and harmless proximity stops remain active.

Asteroids now integrate velocity under scaled planetary tidal gravity and rotating-frame forces, with mass-based rock collision impulses and station rebounds. They no longer follow scripted circles or freeze near the ship. This is a local co-orbiting approximation, not a full solar-system simulation. The station turns slowly at the planet surface rotation rate; its collision volumes rotate with its meshes. Orbital time controls both.

## 2026-10-25 01:21:03 UTC — Viridia peaceful orbital hub

Source commit: [4f77be1](https://github.com/eyehaveewe-cyber/Foxlike/commit/4f77be10d8452613782eca3322fb108da0c0b0ef)

Added Viridia Orbit on the latest flight deck, alongside the existing campaign and Phase One practice duel. The room starts with a stationary ship at an orbital observatory. Six-axis thrusters, hover assist, free momentum drift, brake, boost, safe structural/asteroid proximity stops and an explicit station return support roaming or long idling. The two habitat rings, open docks, solar fields, lit windows and observation cameras frame a large procedural planet with ocean/land/ice, night lights, moving clouds, atmosphere, a moon and sun. Outer asteroid visitors reveal gently and are bounded; orbital time can pause or accelerate independently of ship handling. Added an original sample-free quiet ambient loop with reproducible generation source.

Validation: 26 new hub checks pass, including actual flight-deck entry/return, 30-second idle holding, drift, braking, diagonal speed caps, station and rock clearance, orbital-time separation, bounded visitor admission and fade-in. All 235 existing campaign/duel regressions pass separately. Native views and an eight-second scripted orbit tour were rendered and inspected. Windows/Web exports and source packaging are verified separately below. Physical controller operation and target-machine performance remain unmeasured. This room is an artistic orbit presentation, not an N-body simulation. Phase One's human duel acceptance gates remain open.

## 2026-10-23 18:30:30 UTC — Phase One fair-flight practice implementation

Source commit: [3b8314a](https://github.com/eyehaveewe-cyber/Foxlike/commit/3b8314a905f9845da8341feafcaa151e7ae206b8)

Implemented the complete Phase One guide's technical foundation as Practice Duel on the flight deck: shared nose-directed player/AI flight, matched energy/roll/weapons, solid cover, swept world collisions/projectiles, pitch-aware chase camera, relative-height/rear/stale cues, delayed observation and memory, committed high passes, extension/search, cover routes and one observed-shot evasion. Both arena heights and pitch modes remain reversible experiments. Added local bounded traces with source fingerprints and explicitly labeled arranged native capture. Phase One is **not signed off**: the required human win, explainable loss, cover/high-attack counters, blocked approach and final volume/control selection remain open. See [implementation and review](docs/PHASE_01_IMPLEMENTATION.md). Validation: 38 new duel checks and all 197 existing regressions pass in Godot 4.7.2; Windows/Web exports build. Native arranged flight/camera capture and a paired source-stamped trace were reviewed. No human completion or new browser-runtime verification is claimed.

## 2026-10-23 07:02:21 UTC — Playtest fixes and six-mission expansion

Source commit: [84e9d31](https://github.com/eyehaveewe-cyber/Foxlike/commit/84e9d31428e15d1a5271eddc18dac7d4fe0d5782)

Applied the Foxlike section of the October 22 Crunch-Time Jam notes. Ring and pickup collection now sweeps both pickup and player motion between frames and displays an immediate reward notice. Player missiles start at six, cap at eight, consume ammunition and create an 18-unit area blast; cyan ammo crates add three and green repair supplies add two. Boss weapons have separate health, visible destruction and disabled attacks. A core receives only 8% damage until its weapons are down; Warden now has a 260-health core and two 65-health cannons on Standard.

Added three missions, each with a distinct boss. Cinder uses the Jackal tank with finite-fuel jet packs, grounded recharge, traversable barriers and Iron Maw's siege crawler. Anchorage is a free-flight defense arena around the actual Project Barrel Roll Dragonfly carrier, with incoming attackers, carrier hull damage, radar, Harrow and a 2.4-second climbing turnaround at the rim. Tempest adds a storm route and Crown's four-pylon fortress. Menus, briefings, progression, saves and the final ending now support all six missions; old Terminus clears unlock Cinder. Rail-flight boost stunts remain available on the rail missions.

Imported three 34.909-second excerpts of MBean1's original *The Bone Lantern Ballroom*. They use the unchanged note score and actual pinned MBean1 Web Audio renderer; source score, renderer, regeneration script and [provenance](docs/ASSET_IMPORTS.md) are included. No additional sampled instrument downloads are needed to play.

Validation: all 197 native Godot 4.7.2 assertions pass (74 campaign, 35 squadron, 38 combat revision, 50 expansion). Coverage includes pickup sweeps and near misses, ammo depletion/resupply, area damage, boss subsystem targeting, real hover/barrier collisions, fuel/rearm behavior, arena coordinate and projectile continuity, 20/120 fps turnaround containment, carrier attacks/failure, six boss/result paths and old-save migration. Native screenshots and motion clips were rendered and inspected. Windows and Web expansion exports and the editable source ZIP package successfully. The local browser process still exits before the menu, so no new Web runtime pass is claimed. Physical controller, human balance and native Windows runtime testing remain outstanding. See [playtest resolutions](docs/PLAYTEST_RESOLUTION.md).

## 2026-10-23 00:46:04 UTC — Companion roster, combat and formations

Source commit: [4348b16](https://github.com/eyehaveewe-cyber/Foxlike/commit/4348b161232d9f36da814623260dc2c2a8804f8e)

Added five pilots and two saved equipment slots on the main screen. Latch intercepts shots, Glint fires rapid bursts, Pike unlocks after Viridia with homing missiles, Ember unlocks after Aurora with local Nova blasts, and Bastion unlocks after Terminus with heavier shields and faster interception. Each has separate health, laser rate, damage, ability cooldown and temporary Mk I–III arsenal level. Existing mission unlocks/clear records migrate to roster access; invalid or duplicate selections sanitize to valid distinct pilots.

Added Wide V, Spearhead and Close Guard, selected on the main screen or cycled with Tab / controller D-pad Up. Formation changes move the actual companion ships. Bodyguards predict incoming bolts, fly ahead, and absorb hits with their own shields. Projectiles resolve a blocking companion before the player only when that companion is ahead along the shot path. Ready offensive abilities fire automatically; F / Y commands ready abilities without bypassing individual cooldowns. Violet chevron supplies empower active companions and appear in the route and kill drops. A withdrawn pilot stays out until the next mission refit.

Validation: the existing 74-assertion campaign suite and a new 35-assertion squadron suite pass in Godot 4.7.2. Coverage includes real menu signals, formation input/motion, interception and damage ordering, missiles and Nova impacts, actual upgraded laser damage/rate, independent cooldowns, pause, roster unlocks, loadout persistence/migration, upgrade caps and refits. Native rendered screenshots cover locked/unlocked rosters, all three formations and specialist weapons. Windows and Web exports and the source ZIP package successfully. Physical controller and human balance testing remain outstanding.

## 2026-10-22 21:17:13 UTC — Boost maneuvers

Source commit: [3b730c3](https://github.com/eyehaveewe-cyber/Foxlike/commit/3b730c3c3eb69221e76d5e2ba5eca3696043462a)

Added three boost-direction abilities using Motionwright: left for an in-place somersault, down for the long forward surge and vertical loop, right for a rising corkscrew with gradual forward-position and speed recovery. Keyboard WASD/arrows and the controller stick share the direction detector. Cost is 30 energy, with a shared four-second cooldown. Inputs require a new direction edge, so held controls cannot auto-repeat. The controller owns the actual flight path; the airframe rig adds unclamped full rotations after steering. Pause preserves the path; death, victory, menu and retry clear it. HUD displays action/cooldown, and the controls are in the menu and README.

Verified in Godot 4.7.2: 74 integration assertions pass, including maneuver input, energy, pause, overlap prevention, recovery, no repeat, interruption, edge bounds, and matching 20/120fps sampling. The committed capture harness renders the three moves through the real gameplay update. Windows and Web exports package successfully. Added a browser regression for the boost-down loop and return depth; the local Chromium process closed before the game started, so that updated browser check awaits CI. Physical controller testing remains outstanding.

## 2026-10-22 19:59:35 UTC — Editable source delivery

Source commit: [41ebc14](https://github.com/eyehaveewe-cyber/Foxlike/commit/41ebc149cf589b47053c393873fb6bc569612c1b)

The complete Godot project remains at the repository root, including `project.godot`, scenes, GDScript and audio. Added a prominent direct source ZIP link and import instructions to the README. Added `tools/package_source.py` to check resource inclusion and ZIP integrity and create `build/Foxlike-source.zip` without an engine installation. CI uploads this as the separate `Foxlike-Godot-source` artifact before installing Godot or exporting playable builds.

## 2026-10-22 17:48:41 UTC — First complete campaign

Source commit: [331bb56](https://github.com/eyehaveewe-cyber/Foxlike/commit/331bb563df6b282960298056349f2b447c3533ef)

Implemented under Jonathan's request for a best-effort, one-shot Starfox-like game, with permission to draw from Project Barrel Roll. This repository was empty at the start.

### Delivered

1. Complete three-mission arcade campaign: Viridia coastal blockade, Aurora ice-field relay, Terminus carrier assault; launch, boss, results, retries, mission unlocks, ending and local saves.
2. Responsive 3D rail flight with keyboard/mouse/controller input, continuous twin lasers, target-lock missiles, nova bombs, boost/brake, invulnerable barrel rolls and wingman crossfire.
3. Nine procedural airframes with reactive banking/flaps, thruster animation, articulated/collapsing RIME arms, rotating boss cores, carrier bay doors, pooled debris and shockwaves.
4. Authored encounter timelines, enemy formation/sway patterns, bomber volleys, rescue waves, asteroid slalom, repair/upgrade/ordnance pickups, boss attack cycles and telegraphed carrier lance.
5. Original mission/boss music, synthesized effects, cockpit comms, mute/chatter controls, three difficulty settings, scores/chains and stage records.
6. Native Windows and single-threaded browser export presets, reproducible packaging, CI artifacts, integration tests and committed rendered evidence.

### Evidence and limits

Read `docs/VERIFICATION.md` for actual validation and build status. The integration suite has 50 assertions, including all mission completion paths. The exported Web build also passed 8 real Chromium input/lifecycle checks; CI now includes that regression gate. Automated playthroughs use invulnerability for route coverage and reduced boss health for deterministic completion. Human balance testing, physical gamepad testing and native Windows runtime testing remain separate work.

### Next useful work

Play one complete campaign on the user's Windows PC. Tune aim assistance, dodge readability and boss durability from that session. Then consider branching routes or an all-range encounter, a larger enemy roster, rebinding/accessibility options and voice dialogue. Keep substantial flight feel improvements ahead of cosmetic menu churn.
