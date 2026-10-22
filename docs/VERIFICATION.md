# Verification — 2026-10-22

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
