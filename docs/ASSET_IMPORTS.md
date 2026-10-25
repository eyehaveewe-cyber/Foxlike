# Asset and source imports

These assets were adapted for Foxlike on October 23, 2026 at the repository owner's request. They retain the provenance of the user's projects; this record does not grant a new blanket redistribution license.

## Dragonfly carrier

`scripts/arena_carrier.gd` adapts the actual [Project Barrel Roll carrier hull](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/17bda73b7763c5033cc19e945fd84b12019f0dc6/scripts/carrier_hull.gd), blob `716a6beabebc56cf0fb1943f1a06bc058697dab7`. Its 38 mesh pieces retain the broad head lobes, heavy thorax, seven tapering tail segments, paired eyes and launch doors. The geometry is centered and enlarged to approximately 80 meters long, faces -Z, uses lit materials, and changes hull/window color with damage. `setup()` is idempotent; `animate(delta, clock)` controls restrained tail motion and launch doors; `set_damage(hull_ratio)` supplies damage feedback. Collision, health, movement and mission objectives remain controller responsibilities.

## MBean1 soundtrack

The three OGG loops in `assets/audio/mbean/` are excerpts from **The Bone Lantern Ballroom**, the original authored MBean1 benchmark. The source is [MBean1-Astra at ecd441fe29118995e7036df46ec80fefe8738e9e](https://github.com/eyehaveewe-cyber/MBean1/tree/ecd441fe29118995e7036df46ec80fefe8738e9e). The source composition contains a pulse lead, independent answers, plucked harmony, chip bass, synthesized noise percussion and pitched toms. These excerpts use no recorded instrument samples or commercial-game recordings.

| Foxlike audio | Original section | Source bars, one-based | Duration |
| --- | --- | --- | --- |
| `bone-lantern-hook.ogg` | First dance | 9–24 | 34.909 seconds |
| `bone-lantern-mirrors.ogg` | Mirrors after midnight | 41–56 | 34.909 seconds |
| `bone-lantern-return.ogg` | The dancers return | 65–80 | 34.909 seconds |

The score is unchanged. The excerpts are new renders through MBean1's own Web Audio synthesis code, not copies of the upstream MP3. `render_loops.cjs` repeats each selected section three times and retains the middle pass, preserving release tails at the loop boundary. A common gain retains the relative mix between excerpts and keeps the largest PCM peak at 0.75 before OGG encoding. The recurring hook, contrasting harmony and developed return come from the source composition rather than an invented replacement melody.

The imported files are byte-identical to the following upstream Git blobs:

| Local source | Upstream path | Git blob |
| --- | --- | --- |
| `assets/audio/mbean/bone-lantern-source.json` | `examples/stage6-bone-lantern.json` | `4fbd14834d64a6a3791a1912ca6f02869bb63376` |
| `assets/audio/mbean/renderer/model.js` | `model.js` | `da5cf9e714baf089b3fa71583238c260a5eb3c87` |
| `assets/audio/mbean/renderer/chip-audio.js` | `chip-audio.js` | `d06eb0cd12278c9da1f6d3b5cdcc8d80f5829e6e` |
| `assets/audio/mbean/renderer/audio.js` | `audio.js` | `491fcf4fba1d32a0c560c82fa2026ab67b4cdd2c` |

The imported renderer also contains support for external sampled instruments, but these score tracks do not invoke those branches or download their samples. Its original source comments are preserved. To regenerate the OGG files, install Playwright and ffmpeg, set `CHROMIUM_PATH` if needed, and run `node assets/audio/mbean/render_loops.cjs`. `NODE_PATH` may point at an existing Playwright installation.

Verification: the original score was validated through MBean1's `MusicModel.validate`; the loops rendered with its actual OfflineAudioContext path. Carrier construction, repeated setup, animated doors and damage tint were exercised in native Godot 4.7.2. Audio waveform/level and duration checks establish technical validity; they are not a claim of human listening or final musical balance.

## Project Barrel Roll planet catalog and chart — 2026-10-25

The owner's GitHub plugin supplied the actual source files. `main` contains only the repository README, so the inspected campaign branches provide the implementation. This is direct reuse of catalog/chart code, not a reconstruction from memory.

| Foxlike file | Upstream path / branch | Upstream Git blob | Adaptation |
| --- | --- | --- | --- |
| `scripts/orbit/pbr_catalog.gd` | `scripts/campaign_data.gd`, `codex/release-isolation-flow-verification` | `14ddaf4ee4ef0fab9343a00432b17a2a3daba14e` | Class renamed; twelve-world data retained |
| `scripts/orbit/pbr_system_chart.gd` | `scripts/system_chart.gd`, `codex/campaign-solar-system` | `19e82a75a2a19f8fe62b9e5b0cb798d5dd67dc4b` | Classes/preload path namespaced for Foxlike |
| `scripts/orbit/pbr_planet_visual.gd` | `scripts/planet_visual.gd`, `codex/campaign-solar-system` | `e261a5ae85cbd1ac6f6ee74d87ef9667634f7811` | Class/preload path renamed; hidden previews skip animation work |
| `shaders/orbit/pbr_planet_surface.gdshader` | `shaders/planet_surface.gdshader`, `codex/campaign-solar-system` | `20cf7b0bc6932e335cf503bfe8d609b8fea2b28f` | Source retained for selector/chart thumbnails |

Source links: [catalog](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/release-isolation-flow-verification/scripts/campaign_data.gd), [chart](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/campaign-solar-system/scripts/system_chart.gd), [planet preview](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/campaign-solar-system/scripts/planet_visual.gd), [preview shader](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/codex/campaign-solar-system/shaders/planet_surface.gdshader). Private repository access may be required.

The twelve-card selector is new Foxlike UI around the imported data/renderer. Its system-chart mode uses PBR's original panning, zoom, routes, stars, nebula and planet drawing. Free exploration access replaces campaign gating at the integration boundary; PBR campaign progression and save code are not imported.

All physical 3D sector geometry, moon orbital positions, stable moon IDs, body collision, travel-drive handling, waypoint cues, distance-based detail and the extended 3D surfaces are new Foxlike implementation. The imported data specifies moon counts but no individual moon names or flyable 3D layouts. Their new radii/positions are scaled for play. No external asset download or license change is introduced by this owner-authorized reuse.
