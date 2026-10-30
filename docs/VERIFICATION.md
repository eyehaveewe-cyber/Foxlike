# Verification

## Expanded campaign programming — 30 October 2026

The normal entry now uses the ten-operation campaign. Jonathan’s instruction removes human-check prerequisites from programming; no human results are invented. The [implementation and plan mapping](EXPANDED_CAMPAIGN.md) records the actual contracts and blockout scope.

Official Godot **4.7.2.stable.official.ed1daf0bf** passed **764 checks across 12 native suites**: operations 113, physical delivery routes 11, arranged sequential journey 131, music 156, compact campaign 74, compact squadron 35, combat revision 38, compact expansion 50, shared duel 38, orbit 40, orbit exploration 70 and compact tank support 8. The compact suites retain preserved-content regressions; they do not certify new flight-controller gameplay. The journey fixture arranges combat/arrival events and verifies every operation boundary, cold checkpoint/result reconstruction and idempotent settlement. The route fixture flies the actual controller through authored collision geometry. Walker checks measure planted feet during translation/turning at 20/60/120 FPS; pickups cover swept crossing, one award and a near miss.

The **16 distinct scores and 16 decoded OGG loops** pass score, duration, finite-sample, peak, silence, seam and hash checks. The original twelve score/audio hashes are unchanged. Native audio includes every stream’s real decoder wrap plus ten normal operation launches and their actual boss-state transitions. These results do not claim critical listening.

The final exported Web build passed **14 Chromium checks** at 640 × 360: viewport-fitting menu, normal briefing/launch, soundtrack/advancing decoder/mute, steering, shots, spatial loop with real displacement/energy, pause/resume and no JavaScript or engine-console errors. [Browser evidence](evidence/expanded-web-results.json) and [source/exports/check totals](evidence/expanded-results.json) retain exact versions, hashes and scope.

Windows and Web ZIP exports succeeded. Editable source packaging includes all guides’ extracted-text snapshots, the updated DOCX, evidence, linked media, editable scores and reproduction tools. A fresh extracted source copy passed documentation checks, Godot import and main-scene launch in isolated user storage. The six-page DOCX was rendered and every page inspected; its original design remains intact before the implementation addendum.

Actual Mesa/llvmpipe engine captures cover all ten operation blockouts and 150% menu/settings. [Normal flight](previews/expanded-flight.png), [large UI](previews/expanded-large-ui.png), [large settings](previews/expanded-large-settings.png) and [arranged Cinder inspection](previews/expanded-operation-06.png) are rendered views, not concept art or human playthroughs.

The actual pinned PBR flight lab passed its existing **366 assertions**. The new recovery-pose adapter passed **90 paired checks**, plus an 80-frame actual-engine capture with unchanged tactical state on every frame. [Contract](evidence/pbr-recovery-contract.json) and [four-second pose clip](previews/pbr-recovery-pose.gif) identify its scope. No PBR merge or campaign/tactical change was made.

Rapid native shutdown can report queued audio playback resources; focused final audio/operation tests allow the audio thread to release and complete cleanly. Existing rapid-teardown warnings in preserved suites remain recorded. No script or parse failure is accepted by packaging. Physical controllers, human feel/balance, listening, and the user’s Windows hardware remain unmeasured validation. No site publication was performed; Pages now requires an explicit manual workflow option.


## Documentation and portable source audit, October 30, 2026

`python tools/check_documentation.py` checks all repository Markdown links, local heading targets and the native-suite lists in README and RUNNING. Suite names come from the actual release packager's Python syntax tree. `--write` refreshes only the two marked lists. Negative cases confirm that a missing target and an outdated suite list both fail the check.

The source packager now collects the documentation handoffs, evidence and every locally linked document or preview. ZIP CRC and explicit inclusion checks pass, including the original design DOCX, full Phase One guide, paired duel trace and native recording. A fresh extraction passes its own documentation check, imports with Godot `4.7.2.stable.official.ed1daf0bf`, and launches the main scene. There are no script or parse errors. Existing immediate-exit ObjectDB/resource warnings remain.

This audit changes documentation and packaging, not gameplay. The current compact campaign's earlier test results below do not establish completion of the later expanded phase plans. The [Phase One human completion gates](PHASE_01_IMPLEMENTATION.md#human-validation-record) and arena/pitch selection are still pending. Phase Two's guide requires that accepted configuration before the expanded carrier operation.

## Per-level MBean1 soundtrack, October 30, 2026

All twelve editable projects pass the actual pinned MBean1 model validator. All fifteen JSON artifacts regenerate byte-identically from `phrases.cjs` and `author_campaign.cjs`. The score audit records 92 distinct four-bar phrases and 9,706 events. The validator also checks actual pitched release envelopes and fixed percussion tails against each loop end.

All twelve shipped OGG files decode as stereo 44.1 kHz Vorbis at the score's exact duration, within 0.01 seconds. The maximum decoded PCM peak is 0.624, and the largest last-to-first sample difference is 0.00433. The longest measured silence is 0.6 seconds in Aurora's sparse phrasing. No nonfinite samples, overloads or long empty padding are present. `assets/audio/mbean/campaign/render-report.json` records every source and audio hash and all measurements. Original-versus-cached pulse synthesis produces a maximum PCM difference of zero. These are score and signal checks, not human listening.

Godot `4.7.2.stable.official.ed1daf0bf` passes **467 native checks across nine suites**:

| Suite | Checks | Result |
| --- | ---: | --- |
| Music | 114 | Pass |
| Campaign | 74 | Pass |
| Squadron | 35 | Pass |
| Combat revision | 38 | Pass |
| Six-mission expansion | 50 | Pass |
| Practice duel | 38 | Pass |
| Orbit | 40 | Pass |
| Orbit exploration | 70 | Pass |
| Tank support | 8 | Pass |

The music suite loads all twelve actual streams, compares their durations to the score manifest, waits for native decoding, seeks near the end and observes the Vorbis loop counter advancing. It exercises every real mission's briefing, launch, boss, death and retry events, plus menu return. Additional checks cover repeat requests, midpoint gains, immediate and interrupted transitions, mute and volume during a fade, stage bounds, stop and restart. Test saves remain isolated and are restored.

Windows and Web exports and ZIP integrity checks succeed through `tools/package_release.py`. The packager now runs the music suite before the existing regressions. Existing rapid-teardown ObjectDB and resource-cleanup warnings remain; there are no script or parse failures. Physical-device critical listening, final music-to-effects balance, physical controllers and Windows hardware playback remain unverified.

The exported Web build also passes thirteen real Chromium checks, with no JavaScript or engine-console errors. New checks confirm the imported MBean1 mission stream is playing, its playback position advances after a user gesture, and keyboard mute reaches the audio controller. Existing checks exercise launch, steering, lasers, the long-loop maneuver, pause and resume. This run uses a 640 × 360 software-rendered browser and establishes no hardware performance or critical-listening result. The exact browser version, telemetry and checks are preserved in [browser results](evidence/music-web-results.json).

Reproduce score/audio verification and the native build from the repository root:

```sh
node assets/audio/mbean/validate_campaign.cjs --audio
python tools/package_release.py --godot /path/to/godot-4.7.2
```

## Cinder airborne support — 2026-10-25

Eight new checks pass in `tests/tank_support_smoke.gd`: opposite-edge staggered entry, real projectile firing, withdrawal, support ending with the encounter, retry reset and restoration of ordinary flight formations/yaw. The existing 74 campaign, 35 squadron and 50 expansion checks also pass. Hidden support aircraft are excluded from projectile interception, and ground-mode bodyguard commands are suppressed. The HUD labels the mode AIR SUPPORT PASSES. No rendered capture, controller test or human playtest was performed for this change. PBR’s Bastion/Bulwark are armored airframes with tank roles. Its actual ground walker and RIME boss were located separately; no PBR ground model is imported in this change.

## Asterion orbit sectors — 2026-10-25

Godot 4.7.2 passes **345 checks across seven suites**: 235 campaign/duel, 40 orbit and 70 new orbital-exploration checks. The real flight-deck entry opens the twelve-card selector. Every card loads its correct world, full moon population and ring flag. The adapted PBR chart also selects worlds. All 93 moon IDs are unique, physical bodies fit outside their planets and within the 100 km room radius, invalid IDs leave the world intact, and world swaps detach tethers and reset the berth safely.

A continuous Viridia flight under ordinary input crossed the former 1.8 km boundary and approached its first moon to 298.30 m clearance in **13.72 simulated seconds**, reaching **795.89 m/s**. A deliberate 1,500 m/s engine-off continuation stopped outside the physical sphere. LOD observer changes preserve all body positions while selecting the appropriate shared meshes and cloud visibility. Distant asteroid admission follows the pilot, the lance still acquires there, and waypoint cycling includes every moon and the return station. Unpowered cruise endpoints agree within 1 m at 20 and 144 simulated FPS over five seconds.

Native Compatibility renders compiled the imported canvas shader and extended 3D shaders, and produced inspected grid, original system chart, 800×600 grid layout, giant/ringed/volcanic/ocean/ice views and moon close-ups. The continuous transfer recording is scripted flight using real navigation/collision updates; it is not a human playtest. Windows and Web exports rebuild; source ZIP validation includes all imported resources and new orbit documentation. Actual browser runtime, physical controller, target Windows hardware performance and human flight feel remain unverified. Native teardown still emits the previously recorded ObjectDB/resource cleanup warnings.

- [Twelve-world grid](previews/orbit-planet-grid.png)
- [Reused PBR system chart](previews/orbit-system-chart.png)
- [Chronos ringed orbit](previews/orbit-chronos.png)
- [Physical moon close-up](previews/orbit-moon-approach.png)
- [Continuous moon transfer recording](previews/orbit-moon-transfer.mp4)

Reproduce with `godot --headless --path . --script tests/orbit_exploration_smoke.gd`. Native evidence uses `godot --path . --script tests/render_orbit_exploration.gd --fixed-fps 20 -- --capture-transfer`. [ORBIT_EXPLORATION.md](ORBIT_EXPLORATION.md) records controls, coordinate scales and approximations. Planet selection explicitly changes sectors; moon approaches do not teleport. The new orbit mode does not close Phase One's outstanding human duel gates.

## Viridia Orbit hub — 2026-10-24

Godot 4.7.2 passes 26 new orbit regressions and the 235 existing campaign/duel checks. The new suite clicks the real main-menu destination, verifies a stationary ship over 30 simulated seconds, checks drift and braking, total diagonal/boost speed, real hull and asteroid proximity, pause, independent 0–8× orbital time, visitor admission/caps/reveal and return to the current flight deck. This does not establish a target-hardware frame rate or physical controller operation.

Native Compatibility rendering compiled all five orbit shaders and produced inspected station, observatory, planet and visitor views plus an eight-second scripted flight tour. The final planet has sharper cloud detail, a separate cloud rotation, night settlement lights and an atmospheric limb. Station structural shadows are active; its window and solar tiling use multimeshes. The capture uses real navigation/simulation updates, not a painted scene. Shader/visual review is separate from the headless assertions.

Windows and Web exports succeed; source ZIP validation includes the new `shaders/` directory and all runtime resources. The new hub's actual browser runtime remains unverified here. Native runs report the renderer's V-Sync capability warning and some rapid teardown runs report resource cleanup warnings; no gameplay script exceptions or shader compilation errors remained.

- [Observatory and planet](previews/orbit-observatory.png)
- [Planetary view](previews/orbit-planet.png)
- [Station arrival](previews/orbit-station.png)
- [Orbit flight recording](previews/viridia-orbit.mp4)

Reproduce with `godot --headless --path . --script tests/orbit_smoke.gd -- --test-save` and `godot --path . --script tests/render_orbit.gd --fixed-fps 20 -- --capture-motion`. Normal play enters from **Viridia Orbit / Peaceful Hub**. This optional room does not close Phase One's outstanding human duel gates.

## Phase One practice duel — 2026-10-23

Status: playable implementation for human review; the full Phase One completion gate remains open. The complete supplied guide is preserved at [plans/Foxlike_Phase_01_Fair_Flight_Duel.docx](plans/Foxlike_Phase_01_Fair_Flight_Duel.docx); [PHASE_01_IMPLEMENTATION.md](PHASE_01_IMPLEMENTATION.md) maps its work packages, provisional parameters, ownership and unresolved human observations.

Godot 4.7.2 passed **38 new duel checks**, separately from the **197 existing campaign/squadron/combat/expansion checks**. The entry test clicks the real flight-deck Practice Duel button. Controller comparisons at 20/60/120 simulated FPS measured maximum total speed 59.997 units/s, maximum combined turn 1.120 rad/s and matching final positions within 0.001 units. A quarter-second boost from 38 reached 51.907; braking from 60 reached 35.979. Tests also exercise thin-cover movement and bullets, blocked sight, delayed recognition, bounded last-seen prediction, observed-shot evasion, missed passes, world projectile survival, boundary containment without added protection, pause, actual shield win/loss/reset paths and evidence metadata. These concrete assertions do not establish human-readable combat or fun.

The final release workflow reran all five suites and produced Windows and Web exports. The source ZIP passes resource inclusion and integrity checks. The latest practice source is fingerprinted by `tools/stamp_duel.py`; export packaging rejects stale fingerprints. Physical controller operation, native Windows performance and the new practice mode's actual browser runtime remain unverified here.

The native `tests/render_duel.gd` harness records actual simulated flight under an explicitly arranged driver, plus staged cover and camera scenarios. Reviewed the normal briefing, climb/turn combat, last-seen cue behind solid cover, optional measurements and the low-volume comparison. The [paired trace](evidence/phase1-arranged-trace.json) records its source ID, camera settings, driver type and resolved state. [Native recording](previews/phase1-duel.mp4), [briefing](previews/phase1-briefing.png) and [cover scenario](previews/phase1-cover.png) are committed alongside it. No invulnerability or lowered opponent HP is used for the continuous recording. It is not a human completion attempt. Native rendering reported a V-Sync capability warning; prior rapid teardown runs also reported resource cleanup warnings. No gameplay script exceptions or parser failures remained in the final checks.

Human review still must demonstrate a Standard win by countering a pass, an explainable loss, a cover-driven contact break, a high-attack counter, a deliberately blocked approach, visible escape from poor pursuit and reduced-motion play. Both arena volumes and pitch variants are retained until those comparisons support a selection. A larger assertion count is not a substitute for those gates.

Reproduce:

```bash
python tools/stamp_duel.py --check
godot --headless --path . --script tests/duel_smoke.gd -- --test-save
godot --headless --path . --script tests/duel_scenarios.gd
godot --path . res://scenes/duel.tscn -- --duel-replay
# Native camera + matching arranged trace; optionally add -- --capture-motion
godot --path . --script tests/render_duel.gd --fixed-fps 20
```

## Six-mission expansion — 2026-10-23

Godot `4.7.2.stable.official.ed1daf0bf` imported the project and passed **197 native assertions**: 74 campaign, 35 companion, 38 combat revision, and 50 expansion checks. The release packager reran all four suites, exported Windows and Web, and produced both ZIPs. The source packager checks runtime resource inclusion and ZIP integrity; the editable project includes `project.godot`, all procedural models, music source and renders, scenes, scripts, tools and tests.

The combat regressions fire real homing missiles and twin lasers into the visible exposed core of every boss. They also verify independent subsystem damage, behind-player target rejection, pickup relative sweeps, near misses, ammo consumption, resupply and missile blast radius. Expansion regressions cover tank fuel/landing/rearm, genuine barrier damage versus hover clearance, pause, arena world/projectile transforms, current-frame aiming, model facing, radar, physical carrier impacts, failure/retry, save migration and all six boss/result paths. Turnaround simulations at 20 and 120 FPS remain inside the boundary and resume inward without adding invulnerability.

`tests/render_expansion.gd` ran the actual controller at 20 simulated FPS and produced native gameplay captures. Inspected the six-mission menu, tank lift/barrier clearance/landing, the Dragonfly defense arena, the climbing boundary turnaround and all three new bosses. The captures use an explicitly unlocked save and staged encounters; they are visual evidence, not a claim that a human completed the campaign.

- [Tank hover and landing clip](previews/tank-hover.mp4)
- [Arena turnaround clip](previews/arena-turn.mp4)
- [Carrier defense](previews/carrier-defense.png)
- [Iron Maw](previews/iron-maw.png), [Harrow](previews/harrow.png), [Crown](previews/crown.png)
- [Six-mission selector](previews/six-mission-menu.png)

The local Chromium run exited while waiting for the menu before any gameplay assertion; no new Web runtime pass is claimed. The native render backend reports resource/texture cleanup warnings on shutdown after successful captures; some rapid test teardown also reports remaining resources. There were no parser failures or gameplay script exceptions in the final packaging run. Human balance/playthroughs, physical controller testing, musical listening/mix review and native Windows hardware performance remain open.

The MBean1 import was validated and rendered with its actual note model and Web Audio engine. Decoded OGG durations, peak/RMS levels and loop seams were checked; see [asset provenance](ASSET_IMPORTS.md).

## Original delivery record


Engine: Godot **4.7.2.stable.official.ed1daf0bf**. Compatibility renderer.

## Passed

- All scripts parse and the main scene imports.
- `tests/game_smoke.gd`: **50 integration assertions, 0 failures**. Actual scene/input paths cover boot, briefing, launch, bounded movement, boost, laser hits, lock acquisition, homing impact, roll protection, nova clearing, ring upgrades, repair/ordnance pickups, pause/resume, full route schedules for all stages, boss pod damage, lethal projectile transition, debrief/next, unlock persistence, malformed/out-of-range save fields, defeat and retry.
- Separate logic audit verified a killing boss projectile while other projectiles were active, and clean transition cleanup.
- All nine ship rigs instantiated and animated over 120 ticks each. RIME weapon visibility drives tentacle collapse.
- All three world setups, scrolling updates and resets run. Seven chunks recycle per world.
- Effects exercised beyond their 400-particle and 12-shockwave caps and cleaned/reused.
- Six Ogg tracks and twelve WAV effects load and play in Godot. Looping, mute, volume, bounded sound pool and stop tested. Original audio generation avoids clipping.
- Actual OpenGL rendering under Linux Xvfb/llvmpipe produced the committed title, three mission and three boss screenshots. These are in-engine captures, not concept art.
- Windows and Web exports produce complete ZIP archives; required files and ZIP integrity checked. Final package hashes are emitted in the build manifest.
- Eight seconds of actual RIME combat rendered with banking, firing, boost/brake and two barrel rolls; committed as GIF and MP4.
- Design handoff rendered to four pages and inspected.

## Scope of the evidence

Campaign tests advance real flight time, but protect the test pilot and reduce boss HP for deterministic transition cases. This proves state progression and collision/weapon paths, not that a human can finish on every difficulty. Screenshot harnesses also protect the pilot while arranging representative states.

The native rendered checks use a software GPU. They are visual correctness checks, not performance measurements for the user's GPU. Exporting a Windows executable does not prove it has been run on Windows. No physical controller has been exercised. Browser runtime results are recorded below only after the exported build is actually exercised.

## Reproduce

```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/game_smoke.gd -- --test-save
godot --path . --script tests/render_showcase.gd -- --test-save
python tools/package_release.py --godot godot
```

Render scripts need a real graphics backend (an X display on Linux), not Godot's dummy headless renderer. The test save is restored or removed when the integration suite completes.

The native software-rendered capture runs exit successfully but report unsupported VSync and two approximately 350 KB GL textures at renderer shutdown. No corresponding gameplay script errors occurred. This remaining renderer cleanup warning is not treated as a clean rendering log.

## Browser export

The actual single-threaded Web release was exercised in Chrome for Testing **156.0.8078.47** using Playwright. `tests/web_smoke.cjs` passed **8 assertions** with **zero JavaScript or engine-console errors**: rendered flight deck, keyboard briefing selection, animated launch into flight, right steering, laser fire, paused mission clock, resumed mission clock, and a clean console. The script drives normal keyboard input. A read-only state snapshot is available only with the `?qa=1` URL flag; the test does not alter gameplay state.

This test exposed and resolved a Web-only startup failure: JavaScriptBridge returned a numeric boolean, and comparing it directly with a GDScript boolean aborted initialization. Explicit boolean conversion fixed the startup path. A Web debug export supplied the original script error that the release build suppressed.

The workflow now runs this browser smoke after exporting and uploads screenshots/results as **Foxlike-browser-QA**. It publishes playable build artifacts only after the smoke passes. The local browser check used a software renderer and does not establish target-device frame rate or physical controller support.

To reproduce after exporting Web:

```sh
npm install --no-save playwright@1.62.1
npx playwright install chromium
node tests/web_smoke.cjs
```

Set `CHROMIUM_EXECUTABLE` to use an existing Chromium executable. Results and screenshots are written under `build/web-smoke/`. The smoke starts its own local HTTP server and closes it on completion.

Final browser captures (`docs/previews/web-briefing.png` and `web-flight.png`) were inspected after correcting paragraph wrapping and replacing unsupported symbol glyphs. The final eight-check run is recorded in `docs/web-smoke-results.json`. Input assertions wait for observed game movement and shot counts instead of assuming an arbitrary wall-clock delay is sufficient.

The launch regression now advances the animated briefing before launch and verifies that the player returns to normal flight scale. The final web flight capture also shows this corrected scale. Both release packages were rebuilt after this fix; the native test passed 50 assertions and the browser test passed all eight checks.

The first hosted browser smoke reached `LAUNCH` but exceeded the original 45-second limit waiting for `FLIGHT`. Launch requires at least 65 rendered frames because the simulation caps delta at 0.05 seconds. The fixture now renders at 640 × 360 (one quarter of the previous pixel count), allows at most 180 seconds per mode transition and 45 seconds per input assertion, and records the failed step, last telemetry, canvas dimensions, and elapsed time. These changes retain all eight gameplay checks and the clean-console gate. The inspected 1280 × 720 preview images above remain the final release captures.

The revised 640 × 360 fixture passed locally in Chrome for Testing 156.0.8078.47: eight checks, zero JavaScript or engine-console errors. The hosted rerun is a separate check; the local pass does not establish its result.


## Boost maneuvers, 2026-10-22

`tests/game_smoke.gd` now passes 74 assertions in Godot 4.7.2. Added checks for boost + left/down/right, compact flip versus translated loop, forward displacement, visible full pitch rotation, fire suppression, energy charging, cooldown and held-input behavior, pause/resume, death/retry, roll exclusion, gradual corkscrew recovery, edge bounds and identical path sampling at 20/120 fps. `tests/render_maneuvers.gd` captures 252 frames from the actual simulation with encounters disabled for legibility. This is animation inspection, not a combat balance playthrough. See `docs/previews/boost-maneuvers.gif`.

The updated Windows and Web packages export successfully. The added Web regression covers boost + down and return to normal depth. Local Chromium terminated before menu load, so the updated browser regression is not claimed as locally passing. Native rendering completed the 252-frame capture with no script/parse errors; the software renderer reported texture cleanup warnings on shutdown.


## Companion update

`tests/game_smoke.gd` passes 74 assertions; `tests/squadron_smoke.gd` passes 35. The new suite tests the real main-screen button signal, locked equipment rejection, slot swapping, saved loadout/unlocks, legacy migration, malformed fields, keyboard formation changes and actual ship positions, a guard flying into a hostile bolt and losing health while protecting the player, no passive protection on cooldown, collision ordering with a companion behind the player, real homing missile hits and Nova area damage, laser damage/rate upgrades, cooldown changes, pause, upgrade cap, withdrawal and mission refit. Tests use isolated `--test-save` data and restore it afterward. The release packager runs both suites sequentially before export.

`tests/render_squadron.gd` renders locked/unlocked main screens, all three formations and specialist projectiles through the actual scene. Unlocks are supplied by a capture-only fixture. Committed PNGs are native gameplay/UI evidence, not concept art. The renderer used Linux Xvfb/llvmpipe, so this does not measure Windows hardware or verify a physical gamepad. Companion combat balance needs human playtesting.

### Orbital momentum follow-up

Godot 4.7.2: 32 orbit checks pass, including engine-off boost momentum despite turn/brake/thrust input, restart braking, rotating hull collision alignment, mass-weighted collision momentum conservation and 30/60/144 Hz integration comparison over 30 seconds within 0.1 local unit. The existing 235 checks also pass. Native orbit render completed and station arrival image was inspected. Windows and Web exports rebuilt; browser runtime and physical controller remain unverified. Existing rapid-teardown ObjectDB/resource warnings remain.

The local ship coast retains inertial velocity without planetary gravity; asteroid motion uses a scaled co-orbiting frame with gravity relative to the frame origin and Coriolis/centrifugal acceleration. Station rotation is authored slow axial rotation, not a numerically integrated station orbit. The 1800-unit room edge and collision proximity still stop the ship for peaceful exploration.

### Orbital light lance

Godot 4.7.2: 39 orbit checks pass, including acquisition, spring stand-off, charge/beam state, amplified launch, post-release integrated flight, visitor-disable cleanup and station cover occlusion. The 235 existing campaign/duel checks pass. Native rendering completed; the held lance view was inspected. Windows/Web exports rebuilt. This is scripted verification, not a human playtest or browser-runtime claim. The lance adds fictional energy without ship recoil, and station/ship safety remains peaceful.
