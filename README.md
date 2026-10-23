# Foxlike: Asterion Flight

An original, complete three-mission **3D arcade flight campaign** in the Project Barrel Roll setting. Fly Mara “COMET” Venn's Arrow Mk I with two selectable companions, break a coastal blockade, chase a signal through an ice field, and destroy the command carrier over Terminus.

Built for **Godot 4.7.2 stable**, using the Compatibility renderer. All ships, environments and effects are procedural 3D geometry. Music and effects are original synthesis. No external asset service, account, API key or network connection is needed to play a downloaded build.

![RIME battle animation](docs/previews/flight-animation.gif)

[Higher-resolution animation clip](docs/previews/flight-animation.mp4) · [Viridia screenshot](docs/previews/02-flight-0.png) · [Terminus boss screenshot](docs/previews/03-boss-2.png)

## Download the editable Godot project

**[Download the complete source ZIP](https://github.com/eyehaveewe-cyber/Foxlike/archive/refs/heads/main.zip)**, extract it, then import **`Foxlike-main/project.godot`** in Godot 4.7.2 stable. Press **F5** to play or edit the scenes and scripts. The ZIP includes the scene, GDScript source, procedural ship models, audio assets, and export presets.

The `project.godot` file is at the repository root. On GitHub you can also use **Code → Download ZIP**. The Windows executable package is a separate download.

For a smaller source-only bundle, each new build also provides a **Foxlike-Godot-source** Actions artifact containing `Foxlike-source.zip`. Recreate that package with `python tools/package_source.py`; no Godot installation is needed for packaging.

## Play

**Windows:** open the latest successful [Build playable game workflow](https://github.com/eyehaveewe-cyber/Foxlike/actions/workflows/build.yml), download **Foxlike-playable-builds**, extract `Foxlike-windows.zip`, then launch `Foxlike.exe`. Keep the `.pck` beside it. Godot is not needed for the exported game.

**From source:** open `project.godot` in Godot 4.7.2 stable and press **F6 on `scenes/main.tscn`**, or **F5** to run the project. No editor plugins or package installation required.

**Browser:** the workflow also produces `Foxlike-web.zip`. Serve its extracted directory over HTTP, such as `python -m http.server 8000`, then visit `http://localhost:8000`. The web build uses WebGL 2 and single-threaded WebAssembly. Click the game to enable audio. Optional GitHub Pages publishing is configured but requires the repository's Pages setting and `ENABLE_PAGES` variable; no live site is implied.

See [running and packaging](docs/RUNNING.md) for detailed export instructions.

## The game

- **Viridia — The coast is burning:** sunset coastal city, formation attacks, debris slalom, and the Warden blockade frigate.
- **Aurora — Ghosts in the ice:** crystalline asteroid corridor, ringed planet, crossing interceptors, and RIME's six articulated weapon tentacles. Destroyed arms physically collapse.
- **Terminus — The last light:** orbital shipyard trench, reinforcements, telegraphed lance strikes, and the Sovereign command carrier.

Each route lasts about 90–105 seconds before its boss. Boss duration depends on aim and weapon use; a first full campaign is roughly 8–12 minutes. Each mission restores the ship and ammunition. Defeat offers a mission retry. Completing missions saves unlocks, scores and difficulty-specific records; the final mission closes the story.

The flight rig banks and pitches into movement, flaps respond to throttle, thrusters lengthen under boost, and barrel rolls deflect shots. Boss cores rotate, carrier doors move, weapon arms articulate and collapse, and explosions throw spinning debris through expanding shockwaves. The soundtrack has six distinct mission/boss arrangements.

Three difficulties adjust damage and, on Cadet, target durability and aim assistance. Mission selection unlocks as the campaign advances. Scores reward kills, chains, rings, surviving wingmen, remaining shields and weapon-pod destruction.

## Companions and formations

Choose two distinct pilots in the main screen's companion loadout. Equip LEFT or RIGHT; choosing an already equipped pilot swaps slots. The main screen shows health, laser interval and ability cooldown, with the unlock condition on locked pilots. Loadout and formation persist in your save. Existing clear records migrate automatically.

| Pilot | Role | Health | Laser interval | Ability cooldown | Unlock |
|---|---|---:|---:|---:|---|
| Latch | Flies ahead to intercept incoming bolts | 110 | 0.95s | 9s | Starter |
| Glint | Rapid laser fire and six-shot bursts | 75 | 0.28s | 7s | Starter |
| Pike | Homing missiles | 95 | 0.90s | 11s | Clear Viridia |
| Ember | Traveling Nova with a local area blast | 90 | 1.20s | 22s | Clear Aurora |
| Bastion | Heavy bodyguard with frequent interception | 165 | 1.40s | 4.5s | Clear Terminus |

**Tab**, or controller **D-pad Up**, cycles Wide V, Spearhead and Close Guard during flight. The main screen also has a formation selector. The ships fly into their new positions. Bodyguards anticipate bolts aimed at the player, dash ahead, and physically absorb damage using their own health. They cannot stop every attack, and they withdraw when their shields reach zero.

Companions automatically shoot forward targets and use ready offensive abilities. **F / controller Y** commands any currently ready abilities; it cannot bypass their individual cooldowns. A guard commanded early takes position in front. Nova blasts damage nearby enemies and destroy nearby hostile bolts; they do not spend the player's Nova inventory.

**Violet chevron pickups** upgrade both active companions, up to Mk III. Each level adds 40% of base weapon damage, 22% of base firing rate and 18% of base ability recharge rate. A pickup also restores 10 companion health and removes three seconds of current ability cooldown. Pickups appear in authored supply waves and every fifth kill. Withdrawn companions remain out until mission refit, which restores health and resets temporary weapon upgrades.

[Main-screen roster](docs/previews/companion-roster.png) · [Spearhead formation](docs/previews/squadron-spearhead.png) · [Specialist weapons](docs/previews/squadron-weapons.png)

## Controls

| Action | Keyboard / mouse | Controller |
|---|---|---|
| Steer | WASD / arrows, or move the mouse | Left stick |
| Twin lasers | Space / left click | Right trigger |
| Barrel roll | Q / E | A |
| Boost | Hold Shift | Right bumper |
| In-place somersault | Hold Shift, tap A / Left | Hold RB, flick stick left |
| Long forward loop | Hold Shift, tap S / Down | Hold RB, flick stick down |
| Climbing corkscrew | Hold Shift, tap D / Right | Hold RB, flick stick right |
| Brake | Hold Ctrl | Left bumper |
| Homing missile | R / right click after lock | X |
| Nova bomb | B | B |
| Ready companion abilities | F | Y |
| Cycle formation | Tab | D-pad Up |
| Pause / resume | Escape | Start |
| Mute sound | M | Pause menu |
| Cut / resume chatter | C | — |
| Fullscreen | F11 | — |

Aim at a target until the lock completes, then fire a homing missile. Missiles recharge in 2.5 seconds; companion abilities recharge independently according to the roster above. Nova bombs are limited. **Gold rings repair shields; collecting three upgrades the twin lasers.** Green crosses repair damage, red crosses replenish a nova. Roll through red shots, steer around debris, and move sideways out of the Sovereign's marked lance lane.

Boost maneuvers each cost 30 engine energy and share a four-second cooldown from activation. Hold boost first, then tap the direction. A held direction does not repeat the move. The compact somersault takes 1.25 seconds; the long loop surges forward, completes a vertical loop, and returns to flight depth in 2.65 seconds. The corkscrew climbs to a forward boosted position in 1.8 seconds, then eases speed and position back to cruise over 1.5 seconds. Release boost after a maneuver to rearm ordinary boost. Steering resumes when the path finishes; Q/E barrel rolls cannot overlap it. Somersaults suspend forward lasers and missile locking during the flip. These maneuvers move the actual collision position and do not add barrel-roll invulnerability. Near screen edges the large paths ease toward a safe center before looping.

[Actual maneuver animation](docs/previews/boost-maneuvers.gif)

Mouse movement takes over steering; pressing a steering key or moving the controller stick returns to that input. Release boost after exhausting the engine to rearm it. Use Tab/arrow keys and Enter to navigate menus.

## Development and verification

```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/game_smoke.gd -- --test-save
godot --headless --path . --script tests/squadron_smoke.gd -- --test-save
python tools/package_release.py --godot godot
```

The integration suite exercises real scene state, keyboard input, moving projectiles, lock/missile hits, rolls, bombs, pickups, all three mission routes and boss/result transitions, defeat/retry, and save validation. It uses a separate save file. It does **not** substitute for human playtesting or demonstrate difficulty balance; boss-death cases reduce boss health to make transitions deterministic.

See [verification evidence](docs/VERIFICATION.md), [progress](PROGRESS.md), [design](docs/DESIGN.md), and [source provenance](docs/SOURCES.md). The [design handoff DOCX](docs/Foxlike_Design_and_Handoff.docx) records the brief and implementation choices.

This is a compact first complete game, with room for later refinement. It is an on-rails campaign, not an all-range dogfight simulation. It has no multiplayer, voice acting, rebinding interface or touch controls. Controller bindings are implemented; physical controller testing and Windows hardware performance remain to be checked.

## Project structure

| File | Responsibility |
|---|---|
| `scripts/flight_game.gd` | Flight, combat, campaign, encounters, saves |
| `scripts/flight_squadron.gd` | Companion roster, unlock/save migration, formation offsets and ability stats |
| `scripts/flight_maneuver.gd` | Timed somersault, long loop, corkscrew and recovery paths |
| `scripts/ship_model.gd` | Procedural airframes and animation rigs |
| `scripts/flight_world.gd` | Lit worlds and bounded scenery recycling |
| `scripts/flight_hud.gd` | Menu, briefing, cockpit, radio, debrief, ending |
| `scripts/flight_overlay.gd` | Projected reticle and target feedback |
| `scripts/flight_effects.gd` | Capped particles and shockwaves |
| `scripts/flight_audio.gd` | Music, sound pool and volume |
| `assets/audio/generate_audio.py` | Reproducible original soundtrack/effects |
| `tests/` | Integration and rendered evidence harnesses |
| `tools/package_release.py` | Repeatable Windows and Web packages |

Star Fox is a gameplay reference only. This project does not include Nintendo characters, names, models, music or other game assets. Project Barrel Roll's Asterion setting and procedural design language are used with the owner's explicit permission. No project-wide redistribution license is selected in this initial delivery.
