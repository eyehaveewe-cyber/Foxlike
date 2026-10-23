# Foxlike progress

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
