# Sources and creative continuity

Foxlike: Asterion Flight was commissioned by Jonathan Sanders on October 22, 2026 as a complete first-pass Star Fox-like arcade flight game. The request explicitly permitted reuse of code, theming, and models from the user's Project Barrel Roll repository. Foxlike is a separate project and does not modify Project Barrel Roll.

## Project Barrel Roll

The following source branches were inspected through the connected GitHub account:

| Branch | Inspected commit | Use in Foxlike |
| --- | --- | --- |
| `codex/carrier-deployment` | `17bda73b7763c5033cc19e945fd84b12019f0dc6` | Sharp fighter shapes, visible cockpit/pilot, barrel-roll and somersault references, Dragonfly carrier silhouette, launch staging, and the directly adapted carrier hull used in Anchorage. |
| `codex/rime-tentacle-profiles` | `d9201ae54fe5bcbed6256013fcfa8b2e25813656` | RIME articulated weapon arms, destructible parts, exposed core, Asterion world and pilot identities. |
| `codex/campaign-solar-system` | `2066cd509aeb09b20085ddb3fe23b61a834749d5` | Campaign setting and world structure reference. |

Relevant source files:

- [`scripts/fighter.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/17bda73b7763c5033cc19e945fd84b12019f0dc6/scripts/fighter.gd): procedural Sharp fighter geometry and maneuver animation.
- [`scripts/carrier_hull.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/17bda73b7763c5033cc19e945fd84b12019f0dc6/scripts/carrier_hull.gd): wingless Dragonfly carrier, broad head lobes, segmented tail, and launch doors.
- [`scripts/spider_boss.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/spider_boss.gd): RIME's separate locomotion legs, weapon tentacles, and core shutter.
- [`scripts/campaign_data.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/campaign_data.gd): Asterion worlds, including Viridia, Aurora, and Terminus.
- [`scripts/pilot_roster.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/pilot_roster.gd): Mara Venn / COMET, Ivo Rell / LATCH, and Tess Omi / GLINT.
- [`scripts/chassis_catalog.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/chassis_catalog.gd): Arrow Mk I airframe identity.

The October 23 expansion directly adapts the inspected `carrier_hull.gd` into `scripts/arena_carrier.gd`. It retains the head lobes, thorax, segmented tail and launch doors, with centered/scaled geometry and game-specific damage feedback. Exact blob provenance and changes are recorded in [ASSET_IMPORTS.md](ASSET_IMPORTS.md).

These source links may require access to the user's private repository. Foxlike's real-time flight, encounters, mission sequence, and controls were implemented for this project. Its procedural meshes carry forward the source project's visual ideas; the tactical game's action-point rules are not reused as arcade mechanics.

## New work in this repository

The flight controller, campaign encounters, procedural environments, ship animation rigs, HUD, effects, dialogue, and mission scripts were written for this build. The six-mission campaign, including Cinder's jet tank, Anchorage's carrier-defense arena, Tempest's storm route and their bosses, is Foxlike implementation work. These are not claims that the arcade missions already existed in Project Barrel Roll.

The initial Foxlike music and sound effects are original synthesized audio, reproducible through [`assets/audio/generate_audio.py`](../assets/audio/generate_audio.py). The expansion adds three excerpts from the owner's original MBean1 composition *The Bone Lantern Ballroom*. They were rendered from its unchanged note score using MBean1's actual Web Audio renderer at commit `ecd441fe29118995e7036df46ec80fefe8738e9e`; the score, renderer and regeneration script remain editable under [`assets/audio/mbean/`](../assets/audio/mbean/). See [ASSET_IMPORTS.md](ASSET_IMPORTS.md) for sections, exact source blobs and rendering details. These tracks use synthesized voices without recorded sample packs. No commercial-game recordings or extracted sound banks are used.

The models, scenery, HUD geometry, radio portrait, and effects are generated with code. No downloaded model pack or external texture collection is required. The game uses the Godot 4.7.2 engine and its built-in rendering/UI facilities.

## Reference and rights boundary

Star Fox is the user's gameplay reference: forward-flight shooting, squadron chatter, evasive rolls, and cinematic boss encounters. Foxlike uses its own title and the user's Asterion setting. It does not include Nintendo's characters, logos, dialogue, music, or extracted models, and it is not presented as an official Star Fox product.

This provenance record does not assign a blanket license to the repository or to the user's prior work. The repository owner retains the decision about project licensing and distribution terms. Any third-party engine or export dependencies retain their own notices and licenses.

## Viridia Orbit update

The peaceful orbital room, layered planet shaders, observatory, asteroid visitors and ambient loop are new original procedural work. The original Arrow ship rig is reused. Planet rotation, cloud drift and visitor orbits are deliberately scaled for presentation; no real ephemeris or N-body physical accuracy is claimed. Ambient synthesis source is `assets/audio/generate_orbit_ambience.py`; no external recorded samples are required.
