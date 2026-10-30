# Supplied guide: Foxlike_Phase_04_Aurora_and_Pursuit.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_78dbda2668008191b5552df80e10237a/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 7>

FOXLIKE PHASE 04




Foxlike Phase 4 Aurora and the pursuit
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 4 makes altitude, cover and interception central to two connected operations. Aurora becomes an ice-
field arena in which the player finds the relay, chooses approaches around RIME's articulated weapons and
locates Sovereign's fleet. Across the wake then asks the player to intercept a courier carrying the departure
timing and approach codes that Aurora could not provide. Shrike protects that courier through patient high
positioning, committed diving attacks and punishable recovery. The phase also develops world-space versions
of Somersault, the long loop and the rising corkscrew, preserving their identities while testing real paths,
collision and resource use. Its finished result is a pair of missions where choosing another altitude changes the
fight and where cutting across a route can beat following a target's tail. These are proposed specifications
extending the parent handoff. Existing source evidence is inherited from that audit; no new implementation or
playtest success is claimed.

Scope evidence and dependencies
The current source contains the Aurora mission, RIME's articulated and collapsing weapon arms, individually
damageable boss systems, an armored core rule and three rail-flight boost maneuvers. It does not establish
the expanded ice arena, courier operation, Shrike or spatial versions of those stunts. The existing maneuver
timings are references to preserve and compare, not proof that the same paths work inside the larger world.
[S01], [S02], [S03], [S04]
Consume Phase 1's shared flight envelope, observed contacts, solid cover, camera and world-space projectiles.
Consume Phase 2's companion assignments and rival defeat, withdrawal and recovery state. Phase 3 supplies
stable mission identities, outcome settlement and checkpoint reconstruction. P4.3 specializes an existing rival
lifecycle for Shrike; it must not become the first point at which an earlier Rook encounter can resolve a defeat.
This phase owns two playable missions, RIME's route-sensitive attack opportunities, courier interception,
Shrike's high-pass behavior and the arena maneuver family. It does not add a general scanning game, a fuel
economy, a racing mode or a new procedural navigation system. Use the existing Godot and procedural asset
workflow.
The parent targets are twelve to fifteen minutes for Aurora and ten to twelve for Across the wake. Tune
against useful decisions and actual completion time. A courier cannot be sent around artificial circles or paused
without explanation merely to fill that target.

What the player should learn
Aurora first presents an uncertain location with visible transmission pulses and recognisable ice landmarks.
Climbing gives the player a better view of the relay, while the lower channels give a pursuer fewer firing
opportunities. These are immediate benefits and costs of position. The player should discover them while
making progress, without completing a separate training course.
RIME then turns those routes into a combat problem. An arm tracks a particular opening, commits to an attack
and takes time to recover. The player can remove that arm, bait it into a miss or choose another route. When
the relay falls, the squadron learns where Sovereign's fleet is, but not its current departure timing or safe
approach.


                                                                                                   Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 7>

FOXLIKE PHASE 04


Across the wake makes that missing information concrete. A courier is already moving toward an escape
corridor. The player can follow it, cut across a higher route or suppress Shrike before the next attack. A
successful interception demonstrates that the fastest solution can be a better path rather than higher speed.
By the time the player reaches Terminus, vertical repositioning, attack recovery and an emergency maneuver
should be familiar tools.

P4 1 Ice routes and the relay
P4.1 is Sol Medium. Build an approximately 640-by-640-by-160-unit ice arena with a visible relay destination
and three overlapping route regions. Upper space provides observation and longer firing lines. Middle
channels support exchanges of attack passes. Lower gaps break sightlines but offer less turning room. These
are navigable regions, not invisible altitude lanes that constrain the ship.
Author a small number of large ice masses whose collision, visibility and silhouette agree. Reserve clear
approach and exit space around every important opening. A narrow gap may demand a straight pass, but its
entry must announce that constraint and its exit must provide a recovery direction. Do not place a mandatory
reversal inside a gap smaller than the declared turning envelope.
Use transmission pulses and landmarks to identify the relay through a few useful observation positions. The
player can locate it during combat or by climbing above the main obstruction. Reaching a position can reveal
objective information without adding a scanner inventory, repeated button-hold task or separate detection
statistic. Once found, the relay stays marked for the attempt.
Place RIME so its arms can cover meaningful approaches while leaving readable alternatives. An upper arm can
threaten an exposed climb; a side arm can cover a channel exit. The player should be able to identify which
part threatens the planned route from its orientation and warning. Decorative particles and ice fragments
cannot conceal the only safe exit.
The package output is a complete navigation-to-boss mission with a checkpoint after locating the relay. It
depends on existing cover, target marking and camera systems. A useful first acceptance question is whether a
player can explain why they changed altitude and show the resulting change in exposure.

RIME combat and damaged states
Keep the existing arm-collapse rig as the starting point. A failed arm should retain an identifiable damaged
pose or separated component and stop its associated attacks. Its visible state and target geometry must follow
the same confirmed part condition. The parent audit notes that source weak points follow posed parts, so
cosmetic motion cannot be treated as irrelevant to Foxlike targeting. [S03], [S04]
Propose a more varied core rule than requiring all arms to disappear before any worthwhile attack. Test a
small number of named arm combinations that open the core briefly, alongside an opening after RIME misses a
clearly committed attack. The exact combination and duration remain tuning decisions. The current eight-
percent armored-core damage remains the comparison baseline. [S03]
Communicate the opportunity through an actual shutter or power transition and a stable target cue. A player
who destroys every arm earns the safer, longer core opportunity; a player who exploits an earlier opening
accepts active weapons nearby. Avoid regenerating destroyed arms or undoing earned damage when the core
closes.
Use explicit encounter states for search, tracking, committed attack, recovery, core opportunity and defeat. A
checkpoint restores the arm conditions and finite remaining support groups. Loading cannot bring a destroyed


                                                                                                 Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 7>

FOXLIKE PHASE 04


arm back merely because its collapse animation has ended. RIME's defeat must settle the relay objective once
and provide fleet-location intelligence, leaving the courier's timing and codes still necessary.

P4 2 The courier and attainable interception
P4.2 is Sol Medium. Build Across the wake across two connected Aurora sectors of roughly 600 by 500 by 160
units. The courier carries Sovereign's current departure timing and approach codes. Disable its drive before the
clearly marked departure corridor, then secure the information through the existing objective framework.
Shrike can complicate that work, but defeating Shrike is not the required information source.
The courier uses a declared vehicle profile and an authored route selected from visible conditions. Its speed,
acceleration and turning limits remain fixed for the attempt except for explicit damage effects. It cannot
accelerate because the player catches up, ignore the collision geometry or teleport across a sector transition.
Keep its logical position continuous while scenery is loaded or activated.
Design the route around opportunities to predict. The courier passes a recognisable ice tower, approaches a
fork and aims toward the next opening. The player can cross above that tower and meet it from another angle.
A direct tail chase should remain possible for a skilled shooter, but it should offer shorter firing windows and
greater exposure to Shrike.
Derive the escape window from the actual route length, vehicle profile and attack opportunities. Include the
player's turn, travel, acquisition and likely damage time from the checkpoint. Do not assume a full boost
reserve or a perfect continuous hit. If no ordinary available companion pair can create a credible intercept,
change the route or warning rather than secretly slowing the courier when it is offscreen.
Drive damage creates a persistent visible condition and a declared motion effect. A partly damaged courier
that reaches the final docking area can receive one announced exposed docking opportunity as a recovery
chance. That state is authored before play; it is not an invisible success adjustment. The player still has to
complete the disabling attack.
After disabling the drive, move to a short secure-data state that reuses current target and objective feedback.
Do not add boarding or a second minigame. The player clears immediate threats or holds the already identified
recovery area, then receives the data and a departure objective. The package output includes route progress,
damaged motion, final opportunity, information settlement and checkpoint retry.

Courier states and failure recovery
Use a concise route state sequence: acquired, first sector transit, final sector transit, final opportunity if
earned, drive disabled, data secured, result. A fully escaped courier produces a clear failure. The marker and
briefing must distinguish a route destination from an arbitrary distance at which the target disappears.
Create the pursuit checkpoint before the final sector with a defined courier condition, player position,
resources, companion condition and remaining escort groups. Restoring it must not move the courier farther
along its route, duplicate an escort or award the data twice. Check that the recorded state still permits a real
intercept.
After drive disable, commit a secure-data checkpoint only after resolving that simulation step, with COMET
alive and a valid resume position. Record the disabled drive, remaining escorts and unset data reward. A later
defeat restores that state. If COMET dies before this checkpoint commits, retry the preceding final-sector
checkpoint. A whole-mission restart remains available. Optional rival rewards and required intelligence
settlement stay distinct so an early Shrike victory cannot accidentally complete or break the courier objective.


                                                                                                    Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 7>

FOXLIKE PHASE 04


Treat the sector join as a route-authoring problem, not a cutscene reset. A pursuing aircraft, projectile or
companion may cross it. Use the same coordinate and lifetime rules on both sides, and keep the objective
visible enough that the player does not lose the chase because of a streaming or marker transition.

P4 3 Shrike as a capable recurring pilot
P4.3 is Sol Medium. Shrike is patient, precise and competitive, using an existing Interceptor or Raider family
until a distinct hull is justified. The style begins with a high staging position outside the close fight, a brief
alignment, a committed dive across the pursuit route and a real extension after the pass.
The warning is the maneuver itself. A high contact, a short leveling period and the boost plume show that the
attack is coming. The pilot may announce an intention through a concise line, but the attack remains readable
with optional chatter disabled. Shrike cannot fire accurately through an ice mass or obtain a current target
position from an expired contact.
Choose the attack from observed courier and player positions. If the player is already above Shrike, the pilot
needs a new setup rather than receiving a free height advantage. If the lower escape route is blocked, Shrike
selects another legal extension. If the player holds a better angle and damages the aircraft during recovery,
that is a valid counter.
After a missed pass, the pilot takes time and space to reposition. Do not cancel the loss by snapping
immediately into another attack. A prolonged unproductive orbit should trigger the shared extension or search
logic, not an increasingly impossible turning rate. Higher difficulty may improve the choice of approach and
cooperation, within the declared limits.
Use Phase 2's defeat and recovery states. A disabled Shrike withdraws through a reachable route or ejects
visibly and remains defeated for this encounter. A later appearance at Terminus requires an established
recovery and serviceable hull; the campaign can substitute the tactical role if the chosen narrative outcome
requires it. Keep that outcome in the existing small campaign record.
The package output is one recognisable pilot style, conditional radio lines, repeatable counters and clean
lifecycle transitions. Validate it while the courier still obeys its own route. Shrike should create a decision
between suppression and interception, not make the courier mathematically impossible to reach.

P4 4 Spatial versions of the three stunts
P4.4 is Sol Medium. Preserve the name Somersault and the distinct identities of the compact maneuver, long
forward loop and rising corkscrew. The current rail references last 1.25 seconds, 2.65 seconds and 1.8 seconds
respectively, with a further 1.5-second corkscrew recovery. They use a 30-energy activation cost and a shared
four-second cooldown in the source. Those values do not establish safe or fair arena paths. [S02], [S03]
Author each spatial move as an explicit world path with entry conditions, duration, energy use, swept collision,
orientation and exit state. The controller owns translation and hit geometry. The vehicle rig presents the full
rotation, control surfaces and thrust. Camera roll, shake and framing are separate choices and cannot add
invulnerability or alter the exit position.
Start from the chosen Phase 1 flight profile. At 38 units per second and a 1.12-radian-per-second angular limit,
a constant-speed circular turn has roughly a 34-unit radius and a full circle takes about 5.6 seconds. That
arithmetic explains why a 2.65-second full spatial loop cannot simply claim to use the same ordinary turn limit.
A tighter powered stunt needs an explicit maneuver-specific envelope available to any actor using that move.



                                                                                                       Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 7>

FOXLIKE PHASE 04


Test Somersault as a compact escape and reacquisition move while preserving its agreed exit-heading identity.
Test the long loop as a larger forward commitment with a meaningful recovery position. Test the corkscrew as
forward movement plus altitude change that can alter an approach, followed by a bounded return to ordinary
control. If a variant changes the original maneuver's tactical meaning, flag that decision rather than silently
renaming or substituting it.
Use the arena input decision from D1. The old boost-plus-steering chord conflicts with normal turning while
boosting. Compare the agreed dedicated binding or arena chord without changing rail controls as an incidental
consequence. Input feedback should indicate accepted, unavailable energy, cooldown or insufficient clearance;
one held input cannot repeatedly activate the stunt.
Before activation, test the whole candidate corridor against solid geometry and arena limits. A denied
maneuver leaves ordinary control available and gives brief useful feedback. During execution, collision remains
real. Define cancel and interruption outcomes for defeat, mission transition and permitted recovery, and
prevent overlapping maneuvers even if the activation cooldown expires before a long path finishes.

Maneuver tuning and practical use
Measure each move from low, middle and high starting altitudes, while approaching the carrier-sized obstacle
and an ice channel. Include partial boost energy, brake entry, maximum allowed speed and a nearby boundary
turn. A move should not begin safely and then force the ship through the ceiling because only its first point
was checked.
Compare full and reduced camera motion. The player must be able to reacquire the intended target and
resume ordinary steering after the move without searching for an unexpectedly rotated horizon. Measure the
exit position and actual resource cost rather than judging only whether a spinning ship looks impressive.
Use the courier and RIME encounters to establish a reason for each stunt. Somersault can create a close
escape opportunity if its measured path supports that use; the long loop can turn a missed attack into another
approach; the corkscrew can change altitude while retaining forward progress. These are hypotheses to prove
in the encounter, not promised advantages regardless of geometry.
Keep the existing distinction between defensive barrel roll and the rail boost stunts. The latter currently add no
barrel-roll invulnerability. Do not silently grant the arena versions immunity to make them usable. If a move
cannot serve a useful purpose under its declared collision and resource rules, revise its path or purpose openly.
[S03]

P4 5 Signals authored routes and companion roles
P4.5 is Sol Light after the encounter and maneuver contracts are playable. Tune agreed waypoint positions,
pulse markers, livery, callouts and briefings. Changes to courier escape conditions, AI sensing or stunt
mechanics remain Sol Medium because they alter the behavior the text describes.
Aurora's briefing explains that the relay reveals the fleet region. The pursuit briefing explains that the courier
carries the remaining timing and approach codes. This distinction prevents the second mission from repeating
an already completed discovery. Essential warnings name a visible target or route and remain available with
sound muted.
Pike pressures the courier or an exposed RIME part. Glint rewards a clean sustained angle. Latch covers a
dangerous exit. Ember, unlocked by Aurora, becomes a useful choice against clustered escorts during Across
the wake. Every pair available at the relevant point, including Latch and Glint, must still be capable of success.


                                                                                                     Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 7>

FOXLIKE PHASE 04


Companions obey the same cover and feasible-route rules. A marked target behind ice should prompt
repositioning or a brief blocked-shot response, not firing through the obstacle. Regrouping after a high dive
must produce visible flight back to formation rather than immediate slot interpolation.

A play example and failure case
The player enters Aurora low, loses the relay behind an ice wall and climbs at the next broad opening. The
pulses become visible above the ridge. A pursuing fighter briefly loses contact below. At RIME, the player
removes the arm covering that same opening, then uses the safer exit to make a second pass. The level has
taught a route and made the player's destruction change it.
In the pursuit, Shrike climbs while the courier heads around a landmark. The player sends Pike toward the
courier, keeps clear of Shrike's first dive and cuts across the upper opening. Shrike misses and must extend.
The resulting stern shot damages the courier's drive before the final corridor. Success follows the predicted
route and the rival's committed mistake.
A poor attempt can still be understandable. The player spends all energy in a tail chase, enters the narrow gap
too late and loses the last firing window. The escape marker and debrief identify that result. Retry restores the
final-sector checkpoint with the declared state; the player can choose the upper intercept instead. The game
must not change the courier's speed or Shrike's perception merely because this is a retry.

Reusable assets and handoff contracts
This phase develops arm tracking, committed attacks, recoil, hanging damage, shutters, fighter high staging,
dive commitment, overshoot, extension, rejoin and persistent engine failure. It also develops the sampled
poses for all three spatial stunt families. Reuse is earned through these mission situations rather than a
separate animation showcase unrelated to play.
Keep stable part IDs, pivots, sockets, dimensions, forward/up axes, pose inputs and reset behavior. Confirmed
RIME damage drives both its target geometry and visible state in Foxlike. The PBR adapter may present the
same failure after its own tactical resolver has chosen the result. It must not inherit Foxlike's continuous hit
rules, energy cost or route authority.
For each stunt, retain the world-motion specification separately from the rig pose sequence and camera
treatment. In the PBR flight lab, full, reduced and skipped presentation must leave tactical occupancy, facing,
action costs and combat outcomes unchanged. A successful animation transfer is not evidence that PBR has
implemented the courier mission or RIME's new arcade core rules.
Phase 5 receives the finished mission identity/outcome records, legal interception patterns, Shrike's reusable
behavior profile, proven arena stunts and tested damage poses. It can use those tools for Sovereign's defenses
without creating a faster hidden ruleset for the next boss.

Completion evidence and remaining decisions
Complete the phase when a player can locate the relay through visible evidence, use ice to break a pursuit,
explain a chosen RIME route, intercept the courier through prediction and punish Shrike's recovery.
Demonstrate these outcomes with the starter pair and at least one relevant unlocked alternative, without
debug invulnerability or reduced boss health.
Verify a failed boss retry, a courier escape retry, a disabled rival, a partially damaged courier's final
opportunity, and a load from each authored checkpoint. Confirm finite encounter settlement, no duplicated


                                                                                                   Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 7>

FOXLIKE PHASE 04


data reward and correct Ember access. These checks address real state risks rather than merely mirroring
implementation functions.
Record actual stunt paths and limits at representative frame rates, including blocked activation and
interruption. Run the paired PBR presentation proof for the accepted motions. Human observation must
establish camera recovery, readability and whether the altitude decisions are enjoyable; automated
coordinate checks cannot establish those judgments.
The remaining director decisions are the already flagged arena input and pitch behavior, any tactical
reinterpretation of Somersault, and rival survival tone. Resolve only what blocks this phase. Numerical core
windows, route lengths and reaction parameters remain explicit tuning proposals until the playable
comparisons provide evidence.

Provenance and revision history
Version 1.0 dated 23 October 2026 expands this phase from the Foxlike campaign handoff version 2. The user
requested separate detailed DOCX phase plans, recorded here as H9. The parent retains H1 to H8 and the A3
to A8 design proposals. New encounter details, numerical starting values and implementation choices in this
expansion remain AI-origin proposals. The request authorizes planning, not gameplay implementation or
publication. Source facts retain the dated audit and pinned revision cited below; no new human playtest is
claimed. [PARENT]

Sources and related handoffs
The source links identify the evidence behind the baseline. The other phase documents describe proposed
work and should be read with the parent campaign handoff.
PARENT Foxlike campaign design and handoff version 2
S01 Foxlike original Aurora objective and six mission definitions
S02 Existing rail Somersault long loop corkscrew and recovery samples
S03 Existing maneuver activation resources boss state and weak point handling
S04 Procedural ship and RIME articulated model source
S05 Existing arena speed turn and altitude baseline
S06 Source provenance and Project Barrel Roll continuity




                                                                                                  Planning 1.0 | 7
