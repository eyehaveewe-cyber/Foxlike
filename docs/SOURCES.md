# Sources and creative continuity

Foxlike: Asterion Flight was commissioned by Jonathan Sanders on October 22, 2026 as a complete first-pass Star Fox-like arcade flight game. The request explicitly permitted reuse of code, theming, and models from the user's Project Barrel Roll repository. Foxlike is a separate project and does not modify Project Barrel Roll.

## Project Barrel Roll

The following source branches were inspected through the connected GitHub account:

| Branch | Inspected commit | Use in Foxlike |
| --- | --- | --- |
| `codex/carrier-deployment` | `17bda73b7763c5033cc19e945fd84b12019f0dc6` | Sharp fighter shapes, visible cockpit/pilot, barrel-roll and somersault references, Dragonfly carrier silhouette and launch staging. |
| `codex/rime-tentacle-profiles` | `d9201ae54fe5bcbed6256013fcfa8b2e25813656` | RIME articulated weapon arms, destructible parts, exposed core, Asterion world and pilot identities. |
| `codex/campaign-solar-system` | `2066cd509aeb09b20085ddb3fe23b61a834749d5` | Campaign setting and world structure reference. |

Relevant source files:

- [`scripts/fighter.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/17bda73b7763c5033cc19e945fd84b12019f0dc6/scripts/fighter.gd): procedural Sharp fighter geometry and maneuver animation.
- [`scripts/carrier_hull.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/17bda73b7763c5033cc19e945fd84b12019f0dc6/scripts/carrier_hull.gd): wingless Dragonfly carrier, broad head lobes, segmented tail, and launch doors.
- [`scripts/spider_boss.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/spider_boss.gd): RIME's separate locomotion legs, weapon tentacles, and core shutter.
- [`scripts/campaign_data.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/campaign_data.gd): Asterion worlds, including Viridia, Aurora, and Terminus.
- [`scripts/pilot_roster.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/pilot_roster.gd): Mara Venn / COMET, Ivo Rell / LATCH, and Tess Omi / GLINT.
- [`scripts/chassis_catalog.gd`](https://github.com/eyehaveewe-cyber/Project-Barrel-Roll/blob/d9201ae54fe5bcbed6256013fcfa8b2e25813656/scripts/chassis_catalog.gd): Arrow Mk I airframe identity.

These source links may require access to the user's private repository. Foxlike's real-time flight, encounters, mission sequence, and controls were implemented for this project. Its procedural meshes carry forward the source project's visual ideas; the tactical game's action-point rules are not reused as arcade mechanics.

## New work in this repository

The flight controller, campaign encounters, procedural environments, ship animation rigs, HUD, effects, dialogue, and mission scripts were written for this build. The three-mission campaign and its Warden/Sovereign encounters are this build's implementation choices, rather than claims that those missions already existed in Project Barrel Roll.

The music and sound effects are original synthesized audio generated for Foxlike. The reproducible synthesis source is [`assets/audio/generate_audio.py`](../assets/audio/generate_audio.py); the game plays its rendered OGG music and WAV effects. No commercial-game recordings or extracted sound banks are used.

The models, scenery, HUD geometry, radio portrait, and effects are generated with code. No downloaded model pack or external texture collection is required. The game uses the Godot 4.7.2 engine and its built-in rendering/UI facilities.

## Reference and rights boundary

Star Fox is the user's gameplay reference: forward-flight shooting, squadron chatter, evasive rolls, and cinematic boss encounters. Foxlike uses its own title and the user's Asterion setting. It does not include Nintendo's characters, logos, dialogue, music, or extracted models, and it is not presented as an official Star Fox product.

This provenance record does not assign a blanket license to the repository or to the user's prior work. The repository owner retains the decision about project licensing and distribution terms. Any third-party engine or export dependencies retain their own notices and licenses.
