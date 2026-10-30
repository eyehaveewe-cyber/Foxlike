# Credits

Direction and project ownership: Jonathan Sanders / eyehaveewe-cyber.

Foxlike is an original arcade game implemented for the owner's one-shot build request. Asterion locations, squadron identities and the Arrow/Dragonfly/RIME design language draw from the owner's Project Barrel Roll, with explicit permission. Foxlike's game-specific models, animation, scenery, code and sound effects were created procedurally. The Anchorage carrier directly adapts Project Barrel Roll's Dragonfly hull. The campaign soundtrack has sixteen original MBean1 compositions, authored using Sol 6.1 with extra-high reasoning at Jonathan's request. Each mission and boss has its own cue. All voices are synthesized through MBean1's included audio engine, with no sampled instrument assets. The earlier Foxlike audio and three *The Bone Lantern Ballroom* excerpts remain preserved in the source. Editable scores and rendering code are included. See [source references](docs/SOURCES.md) and [carrier/music provenance](docs/ASSET_IMPORTS.md) for exact commits and distinctions.

Engine: Godot 4.7.2, copyright Godot Engine contributors, distributed under the MIT license. Engine license and third-party notices: https://godotengine.org/license/ and https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt.

Star Fox belongs to its respective owners and is used only as a gameplay reference. No Nintendo game assets are included.

The owner has not selected a project-wide open-source license for Foxlike. Public repository visibility alone does not grant a redistribution license.

Viridia Orbit: original procedural planet/cloud/atmosphere/star and asteroid shaders, observatory geometry and peaceful navigation. The quiet ambient loop is original sample-free synthesis from `assets/audio/generate_orbit_ambience.py`.

Asterion orbit selection reuses Project Barrel Roll's complete planet catalog, original system chart, animated planet-preview controller and its canvas surface shader with the owner's instruction. Names, colors, moon counts, rings and routes are retained; the continuous 3D orbital sectors and moon flight are Foxlike additions. Exact provenance is recorded in [ASSET_IMPORTS.md](docs/ASSET_IMPORTS.md).

Expanded campaign walker: adapted from the owner’s Project Barrel Roll `codex/two-legged-ground-walker` source, `scripts/ground_walker.gd`, Git blob `56c53e4afdd37745f9be8ef589150c1e9b1c71bd`. The donor geometry/gait is preserved with its class name changed to `FoxGroundWalker`; `operation_walker.gd` adds game-owned distance sampling and a gun pose. The import assigns no new project license.

The bounded recovery pose is a Foxlike addition tested against the actual pinned PBR flight lab at `5e34e1fc7824d3099a50deb208bffc47dc824cb0`; the tactical root, AP, cell and combat rules remain PBR-owned. [Provenance and proof](docs/EXPANDED_CAMPAIGN.md).
