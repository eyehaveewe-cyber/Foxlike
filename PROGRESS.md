# Foxlike progress

## 2026-10-29 — Orbital Q/E roll

In the peaceful orbital hub, holding Q/E now rolls the actual ship incrementally around its nose; releasing holds the angle. Z/X replace Q/E for downward/upward thrust. The upright chase camera makes the bank visible. Roll does not alter existing drift on its own, and station/planet reset levels the ship.

Validation: Godot 4.7.2 Web packaging passed all 370 checks, including 17 new roll checks. A real Chromium WebGL2 staging session exercised Q/E, hold/reverse, X thrust, braking, pause and return to the flight deck with no captured errors. Software rendering, physical controllers and human flight feel remain limitations. Phase One human acceptance remains pending. See [roll verification](docs/ORBIT_QE_ROLL_VERIFICATION.md).

## 2026-10-25 — Asterion orbit selection and reachable moons

Reused Project Barrel Roll's complete twelve-world catalog, animated planetary thumbnails and original route chart. Planet Orbits now opens a four-column selection grid with every world available outside campaign unlock rules. Every sector contains its selected 3D planet and full catalogued moon population: 93 moons total across the catalog. Distinct procedural surfaces, atmosphere/cloud configurations and the three source-ringed planets replace the single Viridia backdrop. Each station's identity follows the selected world.

Expanded the local flight radius from 1.8 km to 100 km. Added moon/station waypoint cycling, face-waypoint assistance and a manual travel drive up to 1,500 m/s, with powered approach braking. Moon transfers are continuous navigation, with swept sphere collision and proximity protection. Engine-off momentum, hover and the light lance continue working; asteroids spawn around distant players, and planet swaps clear old visitors/tethers and refit at the new berth.

Distant worlds/moons swap among three shared sphere resolutions and cheaper surface detail. Cloud/atmosphere shells and station details cull with distance/apparent size. Only the selected planet sector is instantiated; the selector is paused and hidden chart animation stops. No target-machine performance claim is made.

Validation: all 345 checks pass across seven suites. New checks cover every world/card/moon/ring, the reused chart, all 93 unique satellite IDs, safe world swaps and continuous moon travel. The Viridia transfer test reached less than 300 m from the first moon in 13.72 simulated seconds at a peak of 795.89 m/s, without crossing a celestial surface. A 1,500 m/s engine-off approach was stopped by the physical moon. Native grid/chart/planet/moon views and a continuous scripted transfer were captured and inspected; Windows/Web exports and editable source packaging succeed. Browser runtime, physical controller and human flight feel remain unverified. See [orbit details](docs/ORBIT_EXPLORATION.md) and [verification](docs/VERIFICATION.md). Phase One's human duel completion gate remains open.

## 2026-10-24 — Viridia peaceful orbital hub

Added Viridia Orbit on the latest flight deck, alongside the existing campaign and Phase One practice duel. The room starts with a stationary ship at an orbital observatory. Six-axis thrusters, hover assist, free momentum drift, brake, boost, safe structural/asteroid proximity stops and an explicit station return support roaming or long idling. The two habitat rings, open docks, solar fields, lit windows and observation cameras frame a large procedural planet with ocean/land/ice, night lights, moving clouds, atmosphere, a moon and sun. Outer asteroid visitors reveal gently and are bounded; orbital time can pause or accelerate independently of ship handling. Added an original sample-free quiet ambient loop with reproducible generation source.

Validation: 26 new hub checks pass, including actual flight-deck entry/return, 30-second idle holding, drift, braking, diagonal speed caps, station and rock clearance, orbital-time separation, bounded visitor admission and fade-in. All 235 existing campaign/duel regressions pass separately. Native views and an eight-second scripted orbit tour were rendered and inspected. Windows/Web exports and source packaging are verified separately below. Physical controller operation and target-machine performance remain unmeasured. This room is an artistic orbit presentation, not an N-body simulation. Phase One's human duel acceptance gates remain open.

## 2026-10-23 — Phase One fair-flight practice implementation

Implemented the complete Phase One guide's technical foundation as Practice Duel on the flight deck: shared nose-directed player/AI flight, matched energy/roll/weapons, solid cover, swept world collisions/projectiles, pitch-aware chase camera, relative-height/rear/stale cues, delayed observation and memory, committed high passes, extension/search, cover routes and one observed-shot evasion. Both arena heights and pitch modes remain reversible experiments. Added local bounded traces with source fingerprints and explicitly labeled arranged native capture. Phase One is **not signed off**: the required human win, explainable loss, cover/high-attack counters, blocked approach and final volume/control selection remain open. See [implementation and review](docs/PHASE_01_IMPLEMENTATION.md). Validation: 38 new duel checks and all 197 existing regressions pass in Godot 4.7.2; Windows/Web exports build. Native arranged flight/camera capture and a paired source-stamped trace were reviewed. No human completion or new browser-runtime verification is claimed.

## 2026-10-23 — Playtest fixes and six-mission expansion

Applied the Foxlike section of the October 22 Crunch-Time Jam notes. Ring and pickup collection now sweeps both pickup and player motion between frames and displays an immediate reward notice. Player missiles start at six, cap at eight, consume ammunition and create an 18-unit area blast; cyan ammo crates add three and green repair supplies add two. Boss weapons have separate health, visible destruction and disabled attacks. A core receives only 8% damage until its weapons are down; Warden now has a 260-health core and two 65-health cannons on Standard.

Added three missions, each with a distinct boss. Cinder uses the Jackal tank with finite-fuel jet packs, grounded recharge, traversable barriers and Iron Maw's siege crawler. Anchorage is a free-flight defense arena around the actual Project Barrel Roll Dragonfly carrier, with incoming attackers, carrier hull damage, radar, Harrow and a 2.4-second climbing turnaround at the rim. Tempest adds a storm route and Crown's four-pylon fortress. Menus, briefings, progression, saves and the final ending now support all six missions; old Terminus clears unlock Cinder. Rail-flight boost stunts remain available on the rail missions.

Imported three 34.909-second excerpts of MBean1's original *The Bone Lantern Ballroom*. They use the unchanged note score and actual pinned MBean1 Web Audio renderer; source score, renderer, regeneration script and [provenance](docs/ASSET_IMPORTS.md) are included. No additional sampled instrument downloads are needed to play.

Validation: all 197 native Godot 4.7.2 assertions pass (74 campaign, 35 squadron, 38 combat revision, 50 expansion). Coverage includes pickup sweeps and near misses, ammo depletion/resupply, area damage, boss subsystem targeting, real hover/barrier collisions, fuel/rearm behavior, arena coordinate and projectile continuity, 20/120 fps turnaround containment, carrier attacks/failure, six boss/result paths and old-save migration. Native screenshots and motion clips were rendered and inspected. Windows and Web expansion exports and the editable source ZIP package successfully. The local browser process still exits before the menu, so no new Web runtime pass is claimed. Physical controller, human balance and native Windows runtime testing remain outstanding. See [playtest resolutions](docs/PLAYTEST_RESOLUTION.md).

## 2026-10-22 — Companion roster, combat and formations

Added five pilots and two saved equipment slots on the main screen. Latch intercepts shots, Glint fires rapid bursts, Pike unlocks after Viridia with homing missiles, Ember unlocks after Aurora with local Nova blasts, and Bastion unlocks after Terminus with heavier shields and faster interception. Each has separate health, laser rate, damage, ability cooldown and temporary Mk I–III arsenal level. Existing mission unlocks/clear records migrate to roster access; invalid or duplicate selections sanitize to valid distinct pilots.

Added Wide V, Spearhead and Close Guard, selected on the main screen or cycled with Tab / controller D-pad Up. Formation changes move the actual companion ships. Bodyguards predict incoming bolts, fly ahead, and absorb hits with their own shields. Projectiles resolve a blocking companion before the player only when that companion is ahead along the shot path. Ready offensive abilities fire automatically; F / Y commands ready abilities without bypassing individual cooldowns. Violet chevron supplies empower active companions and appear in the route and kill drops. A withdrawn pilot stays out until the next mission refit.

Validation: the existing 74-assertion campaign suite and a new 35-assertion squadron suite pass in Godot 4.7.2. Coverage includes real menu signals, formation input/motion, interception and damage ordering, missiles and Nova impacts, actual upgraded laser damage/rate, independent cooldowns, pause, roster unlocks, loadout persistence/migration, upgrade caps and refits. Native rendered screenshots cover locked/unlocked rosters, all three formations and specialist weapons. Windows and Web exports and the source ZIP package successfully. Physical controller and human balance testing remain outstanding.

## 2026-10-22 — Boost maneuvers

Added three boost-direction abilities using Motionwright: left for an in-place somersault, down for the long forward surge and vertical loop, right for a rising corkscrew with gradual forward-position and speed recovery. Keyboard WASD/arrows and the controller stick share the direction detector. Cost is 30 energy, with a shared four-second cooldown. Inputs require a new direction edge, so held controls cannot auto-repeat. The controller owns the actual flight path; the airframe rig adds unclamped full rotations after steering. Pause preserves the path; death, victory, menu and retry clear it. HUD displays action/cooldown, and the controls are in the menu and README.

Verified in Godot 4.7.2: 74 integration assertions pass, including maneuver input, energy, pause, overlap prevention, recovery, no repeat, interruption, edge bounds, and matching 20/120fps sampling. The committed capture harness renders the three moves through the real gameplay update. Windows and Web exports package successfully. Added a browser regression for the boost-down loop and return depth; the local Chromium process closed before the game started, so that updated browser check awaits CI. Physical controller testing remains outstanding.

## 2026-10-22 — Editable source delivery

The complete Godot project remains at the repository root, including `project.godot`, scenes, GDScript and audio. Added a prominent direct source ZIP link and import instructions to the README. Added `tools/package_source.py` to check resource inclusion and ZIP integrity and create `build/Foxlike-source.zip` without an engine installation. CI uploads this as the separate `Foxlike-Godot-source` artifact before installing Godot or exporting playable builds.

## 2026-10-22 — First complete campaign

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

### Orbital hub momentum update

Press **I** or use the options menu to cut/restart the engines. Cutoff disables thrust, hover damping and powered braking; attitude control remains available, and existing velocity survives turns and boost release. Restart engines before using Space to brake. H still toggles powered hover assistance. The outer-room safety arrest and harmless proximity stops remain active.

Asteroids now integrate velocity under scaled planetary tidal gravity and rotating-frame forces, with mass-based rock collision impulses and station rebounds. They no longer follow scripted circles or freeze near the ship. This is a local co-orbiting approximation, not a full solar-system simulation. The station turns slowly at the planet surface rotation rate; its collision volumes rotate with its meshes. Orbital time controls both.

### Orbital light lance

Aim the ship nose at a visible asteroid within 700 m. Press **G / left mouse / controller A** to latch it, then press again to fling. The glowing tether reels the real asteroid toward a stand-off point using a damped spring. Hold for two seconds to charge the fantasy launch from 120 to 320 m/s; ship velocity and part of the asteroid swing velocity carry into the throw. **R** drops the tether without a launch impulse. Solid station cover blocks acquisition and breaks tethers. Returning home, disabling visitors or losing the target releases it safely. The lance works with engines off. Rocks retain ordinary gravity, collisions and momentum after release; the station remains indestructible.

## Cinder tank air support

Tank-mission companions now make staggered five-second strafing passes from opposite screen edges, then withdraw before returning. They fire their real lasers and offensive specialist abilities during the attack window. Bodyguard interception is disabled during ground support; off-screen aircraft cannot intercept projectiles. Normal flight formations are unchanged. Pass timers reset on mission refit/retry.

Inspected Project Barrel Roll `codex/two-legged-ground-walker`: Bastion Assault (`assault_tank`) and Bulwark Fortress (`bulwark`) are armored aircraft chassis with tank roles, not tracked ground tanks. Its actual ground assets include the articulated two-leg walker (`scenes/ground_walker_preview.tscn`, documented in `docs/GROUND_WALKER.md`) and the RIME ground boss. These assets were located, not imported in this change; Cinder retains Foxlike’s existing Jackal tank.

Validation: eight new tank-support checks and 159 existing campaign/squadron/expansion checks pass in Godot 4.7.2. Rendering, physical controller play and a human tank-mission playtest were not performed for this change.
