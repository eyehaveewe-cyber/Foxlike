# Phase One flight duel implementation and review

**October 30 direction:** Jonathan said “don't worry about the human check level instructions.” Human observations below remain a validation record, not a prerequisite for later programming. The [expanded campaign](EXPANDED_CAMPAIGN.md) now consumes the shared controller with reversible defaults.

23 October 2026. Implementation starts from Foxlike main `84e9d31428e15d1a5271eddc18dac7d4fe0d5782` and the complete supplied **Foxlike Phase 1 A fair flight duel**, version 1.0. [Full supplied Phase One guide](plans/Foxlike_Phase_01_Fair_Flight_Duel.docx). The director's follow-up keeps the full Phase One document authoritative; the eight-phase outline provides context. The practice implementation is available for human review. **Phase One is not signed off:** human Standard wins/losses, counterplay and the final arena/control choice remain open.

## Play and compare

Choose **Practice Duel** beside Continue Flight on the main flight deck. The normal briefing exposes the 600 × 600 × 76 and 640 × 640 × 160 experiments, pitch hold versus gradual leveling, and reduced camera motion. Start the Standard duel. WASD/arrows, mouse deflection or the controller stick steer yaw and nose-directed pitch; Space/LMB/RT fires, Shift/RB boosts, Ctrl/LB brakes, Q/E/controller A rolls, Escape/Start pauses. F5 resets the encounter. The pause screen also offers restart and return to deck. The practice operation neither reads nor changes campaign progression.

Developer replay: `godot --path . res://scenes/duel.tscn -- --duel-replay`, optionally add `--duel-low`, `--pitch-level` or `--full-camera`. Replays identify their arranged driver in their trace.

The initial tall volume and pitch hold are reversible provisional defaults. They are **not** a human-selected production configuration. No Star Fox arena dimensions are claimed. Both candidates share the same structure, airframe, speed profile, starting horizontal separation and opponent. Initial height is scaled to each volume's usable space, so that the opponent starts above the player in both.

## Implemented responsibility boundaries

| Owner | Implementation |
|---|---|
| Vehicle | `scripts/duel/duel_vehicle.gd`: shared world position, heading/pitch, velocity, energy, roll, collision and boundary resolution. No player/AI identity enters it. |
| Observation and pilot | `duel_pilot.gd`: visual sensor produces timestamped visible data; delayed memory, state selection, cover waypoints and steering requests are separate from locomotion. |
| Weapons | `duel_weapons.gd`: actual resolved muzzles, forward gun axis, per-owner cooldowns, world travel/lifetime and nearest swept hit. |
| Cover geometry | `duel_geometry.gd`: one world-space structure definition supplies movement, projectiles, sight and chase-camera sweeps. |
| Encounter and presentation | `duel_game.gd`: briefing/results, player requests, rig poses, camera, contact-height/rear/stale cues, traces and visual effects. |

The ten-operation campaign now shares this spatial controller. Jackal retains its separate grounded controller; the campaign’s powered spatial stunt paths check clearance before charging energy. The compact campaign controller remains only as a historical regression fixture.

## P1.1 shared spatial flight and projectiles

`arrow-duel-v1` starts with brake/cruise/boost targets of 22/38/60 world units per second, 1.12 radians/second combined steering, ±65-degree pitch, exponential acceleration response 4/s (0.25-second time constant), 100 energy, 28/s boost drain and 18/s ordinary recovery. Holding exhausted boost cannot rearm it; a released input must rearm it. Defensive roll lasts 0.68 seconds with a 1.15-second cooldown for either pilot. Boundary events do not grant a roll, free energy refill or invulnerability.

Requests contain `steer`, `boost`, `brake`, `roll`, `fire` and an optional named `maneuver`. Resolved state includes world movement, speed, angular rate, resources, denial reasons and collision/boundary events. An unavailable action cannot change motion merely because a pilot requested it. The controller substeps at 120 Hz, uses exponential-distance integration and caps combined input before changing yaw/pitch. Nose pitch directs the full velocity vector; vertical input cannot add speed on top of horizontal motion.

Shared twin lasers travel at 210 units/s, have a 300-unit world range, four-second maximum lifetime, 0.18-second firing cooldown and six damage per bolt. Both combatants start with 100 shield. Both share a 0.06-second small-hit grace and 0.8-second collision grace; a defensive roll rejects damage for its actual phase. Muzzle offsets and gun direction follow the resolved body, bank and roll. Player weapon aim has no invisible target snapping. Target and cover intersections are swept and ordered, with one confirmed outcome for a consumed shot. Aircraft movement sweeps a conservative four-unit body radius against cover; aircraft encounters use relative swept separation. The camera is absent from projectile validity.

Measured neutral solid rig bounds, excluding exhaust, are origin (-3.47, -0.518, -3.10), size (6.94, 1.848, 5.30), with furthest per-mesh bounds corner 3.844 units from origin. The four-unit collision envelope covers that measurement. The model faces -Z with +Y up; engine sockets are (-0.92, -0.07, 1.52) and (0.92, -0.07, 1.52). Reset restores motion through `Vehicle.reset` and presentation through `Ship.setup`.

## P1.2 cover, camera and arena experiments

Both rounded footprints contain the same central solid anchor block: X -30..30, Y 4..48, Z -22..22. This leaves broad routes on both sides and a roof route in both volumes. The 160-unit volume additionally provides high approach and recovery space. The visible floor grid, perimeter masts and horizontal height rings provide reference geometry in Anchorage's existing blue/teal industrial language.

The chase camera starts 20 units behind the flight direction and five above, with a stable world-up horizon and 67-degree field of view. Cover sweeps shorten the camera arm and protect its smoothed return. Reduced motion disables shake and speed-driven FOV; the camera never changes aim, heading or visibility tests.

Selected contacts show above/below/level, a rear-turn cue and shield information only while visible. Last-seen markers use their stored position, age and a different color/mark; they cannot follow an enemy through a wall. After nine seconds, stale presentation disappears. It is intentionally one contact cue, not an omniscient radar ring.

Boundary warning/activation reserves speed-dependent turning clearance plus hull margin. Recovery samples both level-turn directions, brakes through the ordinary acceleration response and uses the ordinary combined angular cap. Roof/floor danger prioritizes leveling rather than an unbounded climb. No position wrap or teleport is used. The opponent does not deliberately commit firing passes into the outer recovery belt. Human review still needs to judge whether a particular recovery feels forced or exposes an unfair window.

## P1.3 observed opponent

The sensor acquires within 260 units and its declared view cone when solid cover does not block sight. Standard recognition waits 0.45 seconds; major choices are evaluated every 0.25 seconds. A delayed observation retains its original timestamp. Hidden samples contain no current position, velocity, input or boost reserve. Last-seen velocity predicts for at most 0.75 seconds, after which the opponent searches stored exits.

States are acquire, approach, commit, extend, search, evade and blocked. Each transition records a reason and observation age. The opponent starts high, lines up a lead approach, commits to a pass and extends after a miss. A five-second poor-pursuit condition opens distance instead of increasing damage. A committed line allows at most eight degrees of correction from recognized observations; it cannot reverse into a new chase, and sight loss ends tracking. This bounded corridor is an implementation choice to make ordinary gun passes viable while retaining a punishable miss.

Static cover routes retain a side waypoint before crossing the block, rather than recomputing a short intersecting diagonal every frame. Body-width lookahead brakes blocked approaches. Observed relative velocity predicts aircraft conflicts up to two seconds and consistently requests a starboard separation. Physics remains authoritative if the steering request is insufficient.

One complete evasion reacts to a visible incoming projectile after recognition, records that projectile observation, requests a lateral break/ordinary roll, and extends after 1.1 seconds. A blocked evasion follows the same cover routing and movement constraints. Pressing Fire is not an observation supplied to the opponent.

## P1.4 measurement and review

F3 exposes optional speed, combined angular rate, energy, intent, observation age, chosen route and denial reason. F8 writes a snapshot; outcomes, reset and return also write traces when samples exist. Files are under Godot's `user://duel_traces/`. Samples are bounded to six minutes at 10 Hz, with a bounded event list. This is a local review tool, not an analytics service.

Each trace records the reproducible source fingerprint, profile, volume, pitch variant, camera settings, driver type, outcome, boundary interventions, camera retractions, observation decisions, damage source and samples. `tools/stamp_duel.py` stamps a hash of all practice source files and its scene; release packaging rejects stale stamps. Automated scenarios identify their driver explicitly. The [native arranged recording](previews/phase1-duel.mp4) has a [matching trace](evidence/phase1-arranged-trace.json); it does not certify a human victory. [Briefing](previews/phase1-briefing.png), [cover sight break](previews/phase1-cover.png), and [low-volume comparison](previews/phase1-low-volume.png) capture the actual scene.

## Reusable presentation vocabulary

The rig consumes the resolved orientation, bank, total-speed thrust ratio, defensive-roll phase and confirmed damage flash. The encounter gives those poses their reusable action context: acquire/approach is attack setup, commit is a firing pass, extend is a missed-pass extension, and reacquired approach is rejoin. Ordinary bank/pitch/thrust remain valid with either pilot. The model's neutral axes, measured bounds, engine sockets and reset ownership are stored as rig metadata and documented above. Camera motion is independent. No tactical PBR roots, AP, occupancy or hit outcomes are changed by this presentation work.

## Evidence and decision register

The engine regression checks compare 20/60/120 FPS movement, total speed, combined turn and pitch caps, pitch variants, player/AI energy and roll parity, boost depletion/rearm, thin cover movement/projectiles/sight, observation delay and memory horizon, bounded evasion, pass commitment, search/extension, camera-independent projectiles, boundary recovery, pause, real win/loss/restart paths and trace metadata. Existing campaign checks are separate regressions and do not certify this new duel.

| Experiment | Current conclusion | Next decisive evidence |
|---|---|---|
| Nose-directed shared flight | Retain for human comparison; automated limits and FPS trajectories hold. | Human full duel with both pitch variants. |
| Pitch hold / leveling | Both retained, hold is provisional default. No director selection recorded. | Compare turning, aiming and recovery with identical staging. |
| 76 / 160 height | Both retained. No final arena selected. | Matched human attempts; count searching, interventions and useful high/low decisions. |
| Perception | Retain delayed observed-contact model; regressions prove loss of hidden truth. | A human baits an attack behind cover and identifies the rejoin. |
| Opponent passes | Retain bounded pass/extension behavior for review. | Human punishable missed pass and explainable loss. |
| Camera | Reduced motion is the initial setting; both variants available. | Full encounter with reduced motion and near-cover visibility review. |

During implementation, arranged brake-circle scenarios exposed a ceiling-recovery loop and a poor firing solution. Those faults were corrected rather than increasing enemy health or damage. Subsequent arranged runs produced real opponent hits and losses in both volumes, with transitions through commitment and extension. They show that the opponent can damage and defeat a predictable flying target under shared limits. They are not human difficulty or enjoyment evidence.

## Human validation record

1. Human Standard win by baiting and countering a committed pass.
2. Human loss that can be explained from the normal camera and confirmed hit source.
3. Cover-driven sight break and reappearance on another route.
4. High-attack counter and a deliberately blocked approach without teleporting or profile violations.
5. Poor pursuit visibly opens distance instead of becoming an endless circle.
6. Repeat with reduced camera motion, compare both volumes and both pitch behaviors, then choose the production configuration.

Those observations have not been supplied and are not claimed. Per Jonathan’s October 30 instruction, they do not block programming. Companions, rivals, recovery, spatial stunts, later operations and paired PBR pose checks are implemented in the expanded campaign; see its implementation and dated verification records.
