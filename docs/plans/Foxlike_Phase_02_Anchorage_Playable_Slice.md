# Supplied guide: Foxlike_Phase_02_Anchorage_Playable_Slice.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_4f736a2158988191bde5365c740c927c/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 7>

FOXLIKE PHASE 02




Foxlike Phase 2 Anchorage as a complete operation
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Deliver a complete Anchorage mission in which the player protects Dragonfly, divides upper and lower
defensive responsibilities with two companions, resists Rook's pursuit bait, disables useful Harrow
components, protects a damaged craft's return and clears the carrier's departure route. The mission ends in a
debrief and can fail and retry from a meaningful checkpoint. This is the campaign's first substantial playable
slice, with a proposed successful-play target of 15 to 18 minutes. Phase 1 supplies the fair spatial controller,
perception, cover and camera. Phase 2 adds cooperation, objective sequencing and recovery while proving one
portable vehicle-motion family in Project Barrel Roll's existing lab. It does not depend on completing PBR's
tactical carrier system. The sequence, timings and new behavior below are proposed implementation detail,
not claims about the current build. [PARENT]

1 What the player should experience
Dragonfly is a place to defend and eventually return to. The mission should let the player become familiar with
its upper surface, underside, bay and departure direction through useful actions. Begin with one clear bomber
approach, then introduce competing responsibilities only after the player can find the carrier and understand
the height cues.
A representative successful run uses Latch to cover the repair approach while COMET climbs to intercept a
bomber. Glint concentrates fire when a safe Harrow opening appears. Rook crosses close to COMET and flees
toward an attractive pursuit lane; the player sees that following would expose the lower side of Dragonfly and
instead marks the real threat. Later, COMET clears the bay approach personally while a damaged support craft
attempts recovery.
The same operation should support a different solution with Pike and Bastion. Bastion holds a nearby carrier
approach while Pike pressures an exposed component, giving COMET time to intercept the bomber early.
These are proposed tactical roles using the existing pilots. A specialist changes the easiest division of labor; no
particular pilot becomes a mandatory key.
The mission should also remain playable after one or both companions withdraw. The player may take longer
or lose optional support, but required objectives must remain physically possible. A critical carrier or required-
cargo loss causes a clear local failure and retry. An optional support craft's loss may produce a different
debrief. The briefing must distinguish those consequences before the player commits.

2 Existing material and entry requirements
The source already contains Anchorage's arena, Dragonfly geometry and carrier health, Harrow, five
companion choices, three formations, ability cooldowns, withdrawal and refit. Current companion placement
is interpolated rather than independent world-space flight, and carrier doors follow presentation timing rather
than a complete recovery operation. The expansion consumes those assets while introducing new control and
mission behavior. [S05], [S06], [S08]
Phase 1 must have selected a usable spatial controller and camera configuration. Its opponent must lose sight
honestly, recover from a failed pass and avoid solid structures without breaking the shared aircraft profile. If
those fundamentals remain unresolved, adding carrier pressure will hide the problem rather than solve it. Use


                                                                                                     Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 7>

FOXLIKE PHASE 02


the 640 by 640 by 160 candidate only if the prior comparison supported it; the volume remains adjustable
from evidence.
The standalone slice reads the current roster and uses the existing mission identity without inserting the ten-
mission campaign order. A test setup can select an alternate existing pair without awarding permanent
unlocks. Phase 3 owns the stable-ID migration and campaign progression rewrite. Phase 2 owns a local
operation-state schema and one working checkpoint so failure can be tested now.
For the slice, use a declared, repeatable carrier starting condition. Phase 6 later supplies the campaign's repair
and damage continuity. Avoid encoding a perfect prior Terminus result into the slice or requiring the
unfinished Cinder mission to produce its starting state. The authored drive-repair need and avoidable carrier
hull damage are separate facts throughout the sequence.

3 Arena layout and objective routes
Place Dragonfly around the middle of the usable height band, with space above and below its hull. Begin with
low approach space around 20 to 50, carrier activity around 60 to 100 and high bomber staging around 110 to
150. Keep these regions traversable in either direction. Dragonfly's approximate 80-unit model length is a
starting reference; final bay and hull clearance must use measured geometry. [S08]
Author a high bomber route, a lower fighter route, a repair-transfer route, a recovery approach and an
outward departure corridor. Routes may share scenery but cannot silently compete for the same narrow
space. Place local action close enough to read, usually within the parent plan's 70-to-180-unit engagement
range. Keep critical work outside the automatic boundary-return belt.
The carrier must be a useful visual obstruction where its collision and sight behavior support it. Passing
underneath should break a specific attack line, not make the player universally safe. Surface details that look
passable need matching collision, while inaccessible recesses should not invite a rescue approach. Give the
player recognizable landmarks at the bay and departure end instead of relying on identical floating markers.
Start with roughly six to eight active hostile pilots, counting Rook within that budget, plus two companions and
COMET. Harrow uses a separately bounded large-ship controller. New waves enter through visible routes and
contain finite aircraft. If a current threat is delayed by avoidance, do not compensate by spawning another on
top of the player.

4 Mission sequence and state transitions
The proposed 15-to-18-minute duration is a pacing target. Advance through completed objectives and
resolved consequences, not a requirement to survive until each timer expires. A skilled player should shorten
an encounter by acting well. Slow play should produce clear pressure and visible progress rather than an
unexplained stalled wave.
Use named operation states with explicit entry and exit events. Each state records which required objects and
enemies exist, what the player is being asked to do, and which events can complete or fail it. Present one
primary objective and, when useful, one subordinate responsibility. Companion callouts may explain the
division, but the objective must remain understandable with chatter muted.

 State                Player purpose                            Advance or recovery condition

                      Locate the carrier and intercept a        Bomber threat resolved and essential control cue
 Orientation
                      readable bomber                           acknowledged


                                                                                                    Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 7>

FOXLIKE PHASE 02



 State                Player purpose                            Advance or recovery condition

                      Cover upper and lower threats while       Finite required attacks resolved and required
 Split defense
                      repair traffic approaches                 delivery secured

                      Keep the defense while countering         Rook defeated or visibly withdrawn and active
 Rook intervention
                      pursuit bait                              objective pressure resolved

                      Choose a component that changes the       Required Harrow defeat condition reached
 Harrow attack
                      next approach                             without losing Dragonfly

                                                                Recovery completed or its declared noncritical
 Damaged return       Protect a readable recovery attempt
                                                                loss resolved

                      Clear the marked route and reform near    Carrier crosses the safe departure trigger and
 Departure
                      Dragonfly                                 debrief settles once



5 P2 1 Companions that can reach their assignments
P2.1 is Sol Medium and depends on Phase 1's controller, perception and collision behavior. Its output is
independent companion flight using the same vehicle-control boundary as enemies. Translate each formation
slot into a moving world-space goal with an arrival tolerance. The aircraft steers toward that goal within its
speed and angular limits; it does not interpolate directly through the hull.
Wide V should preserve mutual visibility and spread firing opportunities. Spearhead supports a committed
attack direction. Close Guard prioritizes reachable nearby protection. The formation's intended purpose should
remain recognizable after the ships slow, separate vertically or take different sides around an obstruction.
Rejoining may take time. Do not accelerate a distant companion beyond its declared profile to restore the
visual arrangement.
Keep the existing quick call for ready abilities and formation cycle. Prototype one additional assignment
interaction for attack marked target, protect objective, cover me and regroup. A held assignment input must
not accidentally trigger the tap ability. Show the selected task, the relevant target or protected object, and a
concise acknowledgement or denial. Do not add a full tactical command screen to this slice.
A guard intercept begins by predicting the incoming threat and the companion's reachable trajectory. If the
interception would require teleporting, crossing solid hull or breaking the turn limit, decline it and announce
that the pilot cannot reach it. The command may instead improve position for the next attack. A failed but
honest response should not spend the ability unless its actual action began; define the cooldown boundary
explicitly.
Target selection combines the assignment, immediate danger, a reachable firing opportunity and the pilot's
weapon role. A guard does not abandon the bay to chase a trivial distant enemy. A rapid gunner does not
continue a poor pursuit indefinitely because its fire rate is high. Assignments should be held long enough to be
legible, with emergencies announced when they justify a change.
Completion requires two distinct successful companion pairings, physically reachable guards, obstacle-aware
formations and a credible rejoin after separation. Test both companions withdrawing. COMET must retain a




                                                                                                    Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 7>

FOXLIKE PHASE 02


feasible way to complete every required task. The current pilot cooldowns and refit rules are the baseline;
tuning those numbers is a separate recorded decision rather than an invisible compensation for weak AI. [S06]

6 P2 2 Carrier defense and the Harrow encounter
P2.2 is Sol Medium. Build the objective state sequence, required repair delivery, Harrow encounter, departure
and local checkpoint. Reuse the existing carrier and boss assets, but make the relationship between a
component and an objective visible. The player should know why a particular gun matters before being asked
to destroy it.
Map at least two suitable Harrow weapon or component roles to different pressures during encounter design.
One threatens the repair or recovery route; another creates an offensive opportunity against Harrow.
Disabling the route-threatening weapon reduces that specific danger. An exposed system may create a timed
core opportunity or otherwise shorten the fight. These are proposed changes to the present boss rules, which
currently use separate weapon health and heavily reduced core damage while parts remain. [S05]
Announce dangerous attacks through actual mechanical preparation, muzzle direction and a reachable escape
route. The warning duration must exceed the route's measured recognition and maneuver requirement at a
realistic entry speed. A safety path that only works with a full boost reserve is insufficient for the required
attack. Component failure disables its attack authority and presents a persistent damaged state, rather than
simply hiding a glowing target.
Required repair cargo must be clearly distinct from optional support craft. A critical delivery destroyed during
its exposed approach causes a visible objective failure and checkpoint retry. Optional losses change assistance
or debrief details without making departure impossible. Do not repeatedly respawn an identical cargo ship
until the player notices the intended one.
Place the initial checkpoint after orientation and the first resolved defense beat, before the mission's
compound pressure. Restore carrier condition, required deliveries, active aircraft, resource state and objective
stage as one coherent snapshot. A retry cannot duplicate a reward, retain a dead target reference or restore a
threat without its warning. In-memory checkpoint recovery is enough for this first prototype if presented
honestly; Phase 3 defines the campaign save envelope and durable continuation.
Departure requires completed repair, the relevant Harrow defeat condition and a cleared route. Dragonfly
then follows a bounded authored path with real clearance. Do not end the mission while its hull is still
occupying a hostile firing corridor. Settle the debrief exactly once after the departure event, and expose the
existing retry and return options without changing unrelated campaign progression.
Complete P2.2 when the player can explain the component choice, shorten the operation through good
decisions, lose through a declared critical failure and recover without stale state. A successful run with reduced
boss HP or debug invulnerability does not satisfy this gate.

7 P2 3 Rook and a damaged craft recovery
P2.3 is Sol Medium and introduces the common rival lifecycle before any later mission requires it. Rook's
personality is a flying behavior: approach conspicuously, offer a tempting chase, then pull away from a
protected route. The bait should be visible to an attentive player. If COMET refuses it, Rook must return to a
feasible objective or attack instead of waiting uselessly outside the fight.
Rook uses the same controller, perception and resources as the other pilots. An early defeat is valid even if it
occurs before a planned line. The common rival state distinguishes active flight, damaged withdrawal, disabled
aircraft, ejection where selected, and confirmed later recovery. Use an explicit outcome for this mission. Do

                                                                                                   Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 7>

FOXLIKE PHASE 02


not resurrect the same rival in the same encounter because the authored sequence expected a later
appearance.
A visible withdrawal needs distance, cover or friendly support to succeed. If COMET prevents it, the outcome
changes. A later campaign return requires the chosen recovery branch; Phase 4 and Phase 7 consume that
record. The final narrative severity remains director decision D3. The slice can use a recoverable disablement
outcome without deciding every eventual conversation.
The damaged recovery craft provides a different task from shooting Harrow. It announces impaired flight,
follows a bounded approach and may need the player or a companion to clear threats. Its engine damage
changes only the declared damaged profile. The rig displays uneven thrust or an affected surface consistently
with that state. Avoid an unexplained random wobble that makes the craft collide after the player protected it
correctly.
Recovery passes through request, approach clearance, alignment, final approach, secured and bay complete.
The carrier opens the relevant doors for the authorized sequence and reserves the lane. If an obstruction or
attack makes final approach unsafe, the craft aborts into a visible holding route and announces another
attempt. An interrupted door animation cannot itself mark the craft recovered.
The required repair supply and this recovery demonstration should be separate objects unless the design
explicitly combines their success conditions. The first slice should preferably use a noncritical support craft for
the recovery demonstration, so a failed attempt has a visible consequence without adding another campaign
lock. If both companions are absent, COMET can clear the lane personally.
Complete P2.3 when Rook can be defeated at an unexpected time, the objective sequence continues
coherently, and one successful and one aborted recovery play without snapping or contradictory state. Test
interruption during alignment, during door motion and immediately before the secured event.

8 P2 4 Prove one portable motion family
P2.4 is Sol Medium. Select one bounded family from the slice, preferably damaged approach, abort, rejoin and
recovery alignment, and prove it in the existing PBR presentation lab. This is an asset and animation proof. It is
not a dependency on completing PBR's carrier rules, pilot survival system or campaign packages.
PBR draft PR12 already imports the Arrow, Raider, Interceptor and Bomber from an older Foxlike revision and
keeps tactical roots authoritative. Preserve that pinned donor until a deliberate asset update is reviewed. Its
model scaling and tactical path offsets are presentation choices, not a reason to copy Foxlike's continuous
controller into the tactics game. PR12 and the later walker work remain unmerged branch implementations.
[S10]
The transferable asset declares its source commit, neutral orientation, dimensions, stable part and socket
names, pose inputs, damage states and start/cancel/finish behavior. Foxlike owns position, collision, health
and recovery completion; the asset owns local pose and visible mechanism state. PBR owns AP, cells, facing,
occupancy and combat resolution. Neither camera owns those outcomes.
In the paired demonstration, play the same confirmed damage and motion intent with full presentation and
reduced presentation. PBR must reach the same tactical result, and the rig must return to a valid neutral or
damaged pose after cancellation. Record a short in-engine capture and the asset version used. A rendered clip
alone does not establish that interruption or tactical authority is correct.




                                                                                                     Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 7>

FOXLIKE PHASE 02


Complete this package with one accepted family, not a catalogue of unfinished animations. Record any missing
socket or incompatible reset behavior as a concrete repair. Keep wider capital damage and walker transfer
work in the later phases that create those situations.

9 P2 5 Mission information and debrief
P2.5 is Sol Light after mission states and command outcomes are settled. Write the fixed briefing, objective
labels, short pilot acknowledgements, failure reasons and debrief lines. Each line refers to a real event. A pilot
cannot announce a clear route while the mission still considers it blocked.
Keep essential information available when sound or chatter is disabled. Distinguish a high bomber, lower
fighter and damaged recovery request through position, shape and short text rather than color alone. Avoid
replacing the main objective with every new radio line. Rook's banter must not cover a targeting warning or
the player's companion acknowledgement.
The debrief identifies carrier survival and condition, required delivery, Harrow outcome, recovery outcome,
companion withdrawals and Rook's state. A score can reward efficient defense, but it must not call an optional
support loss a mission failure after the player already reached departure. The mission's authored drive repair is
reported separately from avoidable hull damage.

10 Verification and tuning priorities
The main acceptance run is an uninterrupted human Standard completion without debug invulnerability,
automatic aim fixes or reduced boss health. Capture one deliberate failure and retry, one alternate companion
strategy, a successful climb/dive counter and a run with secondary camera motion reduced. Keep arranged
animation captures and automated checks separately labeled.
Tune the slice in this order: whether the player can read the objective and routes; whether companions can
reach assignments; whether competing threats are feasible; whether Harrow choices change the fight; then
time and damage pressure. If the operation is too long, shorten empty travel and repeated threat patterns
before increasing the weapon damage of every actor.
Useful measurements include time spent searching for the next responsibility, forced boundary interventions,
unreachable guard attempts, time between a recovery request and a clear lane, and active pilot count during
the largest overlap. Treat the 15-to-18-minute target as evidence to interpret, not a reason to add waiting. A
much shorter but complete mission may be the better slice.
Automated checks should target duplicate departure/debrief settlement, checkpoint restoration, invalid
targets after rival defeat, collision during formation rejoin, and bay-lane interruption. Profile the actual six-to-
eight-hostile configuration before raising population. Repeated calls must converge to one operation result
rather than granting another reward or spawning another carrier.

11 Decisions and the campaign handoff
The slice still needs director feedback on the companion assignment interaction, Rook's tone and whether the
first recovery loss is optional. Recommend retaining familiar quick abilities and adding one separate

assignment control, using dry provocation for Rook, and demonstrating recovery with a noncritical craft. These
are proposed choices within the requested campaign, not adopted interface changes.
Hand Phase 3 the operation state model, checkpoint snapshot, finite wave entry rules, objective
completion/failure events, companion assignments, formation recovery and common rival outcomes. Hand


                                                                                                       Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 7>

FOXLIKE PHASE 02


Phase 6 the carrier repair, bay and departure stages so it can connect prior missions without building a second
recovery system. Hand Phase 7 the same rival and recovery contracts for the ending.
Authorship and revision: H9 is the user's request for expanded phase DOCX files. This document elaborates
parent A4, A5, A7 and A8 and preserves the original P2.1 through P2.5 work packages. Current source material
is inherited from the dated October 23 audit. The complete slice, new AI and recovery sequence remain
proposed and unverified. Version 1.0 supplies a detailed Phase 2 handoff within the existing campaign plan.
[PARENT]

Sources and related handoffs
The source links identify the evidence behind the baseline. The other phase documents describe proposed
work and should be read with the parent campaign handoff.
PARENT Foxlike campaign design and handoff version 2
S05 Audited game controller carrier defense and boss damage
S06 Companion roster formations and ability parameters
S08 Carrier model provenance and imported asset notes
S10 PBR flight lab on the inspected unmerged draft




                                                                                                 Planning 1.0 | 7
