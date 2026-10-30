# Expanded campaign implementation

30 October 2026. Jonathan requested implementation of the documentation and clarified: “don't worry about the human check level instructions.” Human review remains useful validation; it does not block programming. Pitch hold, reduced camera motion, restrained rival outcomes and assisted emergency handling are reversible implementation defaults, not invented playtest findings.

The normal `scenes/main.tscn` now opens ten stable-ID operations. The earlier compact campaign is retained in an excluded [regression fixture](../tests/compact_campaign.tscn) and [historical record](../COMPACT_CAMPAIGN.md). Practice and peaceful orbit navigation return to the current deck.

## Source plans and implementation

| Guide | Programming implementation |
| --- | --- |
| [Phase One](PHASE_01_IMPLEMENTATION.md) | Shared nose-directed controller, observed pilots, world weapons, solid cover, camera, trace/restart tools. Campaign aircraft consume that controller. |
| [Phase Two](plans/Foxlike_Phase_02_Anchorage_Playable_Slice.md) | Independent companions and assignments; finite split-defense operation; required delivery, Rook, functional Harrow, damaged support approach/abort and repaired departure. |
| [Phase Three](plans/Foxlike_Phase_03_Opening_and_Evacuation.md) | Warden opens the crossing before full defeat. One lead ferry persists through sheltered and final sectors. Stable-ID progression and six-index migration preserve records and access. |
| [Phase Four](plans/Foxlike_Phase_04_Aurora_and_Pursuit.md) | Low/middle/high ice cover; RIME target positions share the rig’s arm function; Shrike high staging; separate courier drive; information recovery; three actual spatial stunt envelopes. |
| [Phase Five](plans/Foxlike_Phase_05_Sovereign_and_Ground_Corridor.md) | Bay reserve, drive movement/core-window consequence, contact antenna and warned lance; extraction overstrain; three tank yards, ground/hover alternatives, finite fuel and PBR walker with separate gun/leg damage. |
| [Phase Six](plans/Foxlike_Phase_06_Carrier_Continuity_and_Emergency_Flight.md) | Cinder cargo identity carries into required repair delivery. Carrier hull and authored overstrain remain separate. Overspeed/coupling/stabilizer interventions create stable emergency checkpoints; three bounded solid wreck sections share visible and collision state. |
| [Phase Seven](plans/Foxlike_Phase_07_Rivals_and_Campaign_Ending.md) | Three Stormbreak controls, finite rival lifecycle, eight-second weather forecast, Crown’s four functional systems, 28-second cycle/eight-second core opening, bounded launcher pairs, confirmed-victory escape checkpoint, reassembly, playable bay return and outcome text. |
| [Phase Eight](plans/Foxlike_Phase_08_Campaign_Completion.md) | Cold-serializable objective checkpoints, idempotent settlement/replay protection, keyboard/controller button binding UI, held-input rearm, focus/disconnect pause, independent camera settings, 150% UI option, source/export tools and paired PBR pose proof. |

The supplied guides are preserved as extracted-text snapshots with links to their original Library DOCX files. Direct DOCX transfer was blocked by this environment’s network policy (HTTP CONNECT 403 on the signed `oaiusercontent.com` hosts). Connector reads supplied the guide text; that packaging limitation did not block implementation.

## Ownership and rules

`operation_catalog.gd` owns mission identities, finite state definitions and provisional layouts. `operation_session.gd` owns actor motion, objectives, damage, resources, carrier/rival facts and checkpoints. `operation_actor.gd` stores explicit actor state. `campaign_save.gd` owns boundary normalization, version migration, durable writes and result settlement. `expanded_game.gd` displays the resolved state, takes input and changes scenes. The camera and presentation do not settle gameplay outcomes.

Flight actors share `duel_vehicle.gd`; a damaged transport declares its slower profile explicitly. Hostile pilots receive timestamped observations through `duel_pilot.gd`. Cover is authoritative for movement, sight, shots and camera sweeps. Bullets and homing missiles travel in world space. Actor contacts and projectile hits are swept. Up to eight active hostiles are admitted from a finite queue; Standard permits two simultaneous firing requests. Companions obey their own firing intervals, forward arcs, health and cooldowns.

Supplies retain rings/repair/ammunition/Nova/companion upgrades in the expanded campaign. Collection sweeps the player’s actual path, caps inventory and removes each award once. Checkpoints retain collected resources and temporary laser/companion levels.

Companion tap abilities and held assignments are distinct. Invalid attack targets and unreachable guard approaches are denied. Actual flight, aiming and world shots perform the work. A withdrawal stays out of the sortie; checkpoint retry restores its settled condition. The next operation supplies an explicit carrier service boundary rather than healing during combat.

Required craft loss and Dragonfly hull depletion fail the current operation. Optional support loss produces a debrief consequence. Recovery holds outside the lane when threatened, resumes a physical approach after clearance and completes from craft arrival rather than door animation. The ferry keeps one actor identity and its damage across sectors. Clearing the sheltered transfer provides one announced emergency patch to a minimum 45% hull; it remains damaged and slow, and a destroyed ferry is never recreated. The courier has a separately damageable rear drive; destroying the required hull is a failure, not a successful intercept.

Boss systems own the behavior they disable: queued batteries check the same system before launching, the antenna only shares aged observed contacts, drive damage changes movement and openings, and launchers cancel unlaunched pressure without deleting existing aircraft. Crown can be beaten through its timed core opening with vanes still intact. Its defeat is confirmed before constructing the escape checkpoint. Later retries cannot restore the boss or pay its reward twice.

## Persistence and reuse

Save version 2 maps old indices explicitly: Viridia, Aurora, Terminus, Cinder, Anchorage, Tempest retain their original identities. Newly inserted operations receive new IDs. Stored records are normalized at input. Duplicate result settlement converges; an earlier replay cannot replace canonical carrier/rival/rescue facts, the frontier or the ending. Writes use a temporary file and backup. A missing primary can recover the backup; unreadable/future data is preserved for an explicit recovery choice.

Objective checkpoints contain actors, declared profiles, resources, conditions, removed systems, finite arrivals and stable emergency pose. Restore validates required fields, finite vectors, unique identities, parts and profiles before changing live state. Projectiles and recognition are deliberately reset at the authored retry boundary, with attacks warning again; this is an objective checkpoint, not an arbitrary mid-frame save.

The walker model is pinned to PBR blob `56c53e4afdd37745f9be8ef589150c1e9b1c71bd`; the class name is adapted and the local adapter samples its gait from resolved root distance. The model never owns the actor root. [Credits](../CREDITS.md) retain provenance.

`airframe_pose.gd` supplies a bounded damaged/abort/rejoin/alignment family. The [PBR contract evidence](evidence/pbr-recovery-contract.json) records 90 checks against actual draft-lab revision `5e34e1fc7824d3099a50deb208bffc47dc824cb0`. Full, reduced and skipped local poses preserve PBR AP, cells, facing, occupancy, HP, orders and RNG. Cancellation retains the confirmed damaged pose. The original PBR lab’s 366 checks also pass. No PBR merge or tactical/campaign change was made. Rerun in a disposable pinned checkout with `tools/check_pbr_recovery.py --pbr PATH --godot GODOT`.

## Verification scope

The operation suite checks ten starts, finite budgets, snapshots/retries, invalid data, recovery interruption, courier disablement, emergency boundaries, stunt clearance, hover fuel, replay and settlement. The route suite flies actual delivery trajectories through collision geometry; it does not move transports directly to destinations. The journey fixture arranges combat/arrival events to verify every objective boundary and cold result reload across ten operations. It is a state/settlement proof, not a human campaign playthrough.

The exported browser suite uses normal keyboard input and opt-in read-only telemetry for menu fit, briefing, music playback/mute, flight, steering, shots, spatial loop, pause/resume and console errors. Dated counts and artifacts belong in [VERIFICATION.md](VERIFICATION.md). Historical compact suites remain regression evidence for preserved content, not proof that a different controller has been played through.

Human feel and difficulty tuning, physical controller operation, critical listening, and target Windows hardware performance remain unmeasured. Layouts and warning timings are implemented blockout defaults. These validation limits do not reintroduce a programming gate. No site, commercial release or PBR merge is part of this work.

Actual-engine evidence: [150% UI](previews/expanded-large-ui.png), [normal flight](previews/expanded-flight.png), [Cinder blockout](previews/expanded-operation-06.png), [PBR recovery-pose clip](previews/pbr-recovery-pose.gif). The operation inspection views use explicitly arranged states and an inspection camera; they are not human gameplay.
