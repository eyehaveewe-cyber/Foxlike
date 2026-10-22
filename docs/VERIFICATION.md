# Verification — 2026-10-22

Engine: Godot **4.7.2.stable.official.ed1daf0bf**. Compatibility renderer.

## Passed

- All scripts parse and the main scene imports.
- `tests/game_smoke.gd`: **49 integration assertions, 0 failures**. Actual scene/input paths cover boot, briefing, launch, bounded movement, boost, laser hits, lock acquisition, homing impact, roll protection, nova clearing, ring upgrades, repair/ordnance pickups, pause/resume, full route schedules for all stages, boss pod damage, lethal projectile transition, debrief/next, unlock persistence, malformed/out-of-range save fields, defeat and retry.
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
