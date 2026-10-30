# Supplied guide: Foxlike_Phase_07_Rivals_and_Campaign_Ending.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_cf0e391a3c188191bb2c59a39980d99e/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 7>

FOXLIKE PHASE 07




Foxlike Phase 7 The rival resolution and ending
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 7 completes Foxlike with two operations that ask the player to use the campaign's accumulated skills.
Stormbreak makes familiar rivals dangerous through cooperation, then gives their defeat a visible, consistent
resolution. Beyond the storm turns Crown's four vanes into a choice about how to approach the core. The
player then escapes, finds the squadron and returns to Dragonfly. This document expands the approved
planning scope into proposed encounter states, work packages and acceptance evidence. It consumes the
earlier flight, companion, damage and checkpoint contracts rather than redesigning them. Its boundary is a
playable ending whose routes and consequences work before Phase 8 examines the whole campaign. All new
dimensions, timings and encounter details remain AI-origin proposals. No implementation or new human
playtest is claimed.

Scope and source baseline
The source baseline remains Foxlike main at 84e9d31428e15d1a5271eddc18dac7d4fe0d5782, inspected on 23
October 2026. It contains Tempest, Crown, multipart boss damage and generic defeat effects. The campaign
handoff proposes Stormbreak, functional Crown vanes, persistent rival outcomes, an authored escape and a
playable return. These are development targets, not features established by the source audit. Continue in the
existing Godot 4.7.2 project and preserve its characters, ship families and campaign identities. [S01] [S05] [S19]
Stormbreak should last roughly 12 to 15 minutes and Beyond the storm 18 to 22 minutes in successful play.
These inherited pacing targets include approach, combat and resolution. Encounters advance when objectives
change, without holding the player for a scheduled minute. Crown remains the final threat. Defeating it opens
the evacuation route and earns a quiet return with the ships the player helped save.
This phase owns the final rival cooperation, the fortress's functional choices and the ending sequence. It does
not add another adversary, an equipment economy, a relationship score or a new flight model. Earlier optional
losses may change who appears and speaks. They cannot remove the essential route to completion.

Dependencies and inherited interfaces
Begin encounter production after the earlier contracts have demonstrated their intended behavior. Phase 1
supplies bounded three-dimensional steering, perception, collision avoidance, camera information and
boundary recovery. Phase 2 supplies companion assignments, rival disable and recovery states, and carrier
arrival, abort and bay occupancy. Phase 3 owns stable mission IDs, checkpoint settlement and old-save
migration. Phase 4 supplies Shrike's dive and the approved arena maneuvers. Phases 5 and 6 supply
component failure, major wreck collision and deterministic escape states. [S19]
Use tempest_stormbreak and tempest_crown as the proposed stable identities already listed in the parent
plan. Read rival availability from settled campaign records. A recovered pilot needs an established recovery
and repaired or replacement hull before appearing again. A missing pilot leaves a defined tactical-role fallback.
No encounter may silently clear that pilot's previous defeat.
Consume the selected companion pair, their condition, carrier condition and rescue outcomes through the
existing campaign interface. Preserve separate authored Dragonfly drive overstrain and preventable hull



                                                                                                   Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 7>

FOXLIKE PHASE 07


damage. The finale recognizes the repair accomplished through Cinder and Anchorage; it does not break the
drive again merely to manufacture another emergency.

Stormbreak arena and readable weather
Block out Stormbreak inside the proposed 640 by 640 by 180 usable volume. Begin with cover and short
sightlines around heights 20 to 55, corridor controls around 70 to 110, and exposed observation space around
125 to 165. These are loose locations for useful geometry. Pilots may cross between them freely, subject to the
shared flight envelope and measured perimeter clearance.
Use three corridor control towers as a provisional content budget. Their visible machinery governs local route
access. Disabling them gives the fleet a passage to Crown; it does not disable Crown's separate storm-control
vane. Put the first control near the approach so the player can recognize its effect before the remaining
controls demand attention under rival pressure. All towers must be attackable with ordinary weapons and any
available companion pair.
Weather forecasts a danger region before that region becomes damaging. Start an experiment with eight
seconds of warning and three seconds of active danger, then measure an actual escape from the worst legal
entry heading at brake speed and zero boost. A roughly 60-unit nearest safe route is a layout starting point,
not proof of fairness. Reject layouts whose measured turn, travel and recognition time consumes the warning.
Keep a second usable exit and prevent successive fronts from sealing both.
Show the forecast through a persistent boundary shape, a directional marker and a short essential caption.
Lightning brightness and optional radio add emphasis. They never supply the only warning. Weather does not
randomly reverse controls, reveal an unseen target to AI or grant a rival protection from the same hazard.

Rival cooperation and its counters
Shrike stages high, levels briefly and commits to a crossing dive. Rook works near low cover, encouraging a
pursuit that leaves the corridor exposed. Slate watches the currently vulnerable partner and moves to cover its
recovery. Their strength is a sequence the player can interrupt. They use the same sensing, steering, energy
and collision rules proved earlier. Increase neither health nor turning rate simply because this is the final
encounter.
Represent cooperation with an explicit attack assignment and a covering assignment. Slate requests a route
that does not intersect Shrike's dive corridor, then covers the extension after the pass. Breaking shared
sightlines or forcing Slate toward a damaged partner interrupts that arrangement. The companions can exploit
the gap through their existing attack, cover and regroup orders. A short spoken order should correspond to a
visible reassignment.
Count covering fire within the existing difficulty's committed-attacker budget. A pilot that is climbing, waiting
for clearance or protecting a withdrawal remains a real aircraft but need not constantly shoot. When a partner
loses contact, it searches the last known area under the Phase 1 sensing contract. It cannot use the player's
concealed current position to preserve a perfect pincer.
Completion requires the corridor controls disabled and the active rival defense defeated, withdrawn or stood
down through legitimate states. Ordinary fighters may fill a missing tactical role using existing assets. Do not
replace an absent rival with an invisible equivalent or require three named kills. The reduced roster should
remain comprehensible and leave the earlier success valuable.




                                                                                                   Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 7>

FOXLIKE PHASE 07



A Stormbreak play example and recovery
Comet enters with Glint and Bastion. The first disabled tower opens a visible gap in the local interference.
Rook drops beside the lower structures and offers a chase. The player follows briefly, hears a forecast and sees
Shrike staging above the middle control. Returning toward the objective is the useful choice. Bastion covers
the staging approach while Comet breaks sightlines below the structure.
Shrike commits against the last clear approach and must extend after missing. The player marks Shrike for
Glint, then attacks the corridor control while Slate moves to cover its partner. A second pass can pressure Slate
during that move. The pleasure comes from recognizing the opponents' plan and creating an opening, rather
than outlasting three large health bars.
A plausible failure is pursuing Rook into the next forecast region with no boost reserve. The warning still
permits a legal escape, but the player reacts late and loses the craft. Retry restores an authored staging
checkpoint after the first control, including the actual rival roster and settled component state. It does not re-
award the tower or erase an earlier disable. Replaying with Latch and Pike changes who covers the approach
and how quickly a control can be pressured, while leaving the same route to success.

Rival defeat and final resolution
Use the Phase 2 encounter states for active flight, disabled craft, damaged withdrawal, ejection or recovery,
and settled outcome. A rival remains vulnerable while physically leaving an active fight under the established
rules. On reaching a valid departure or recovery state, record the outcome once. Do not despawn the pilot
during a valid firing opportunity or restore an undefeated version in a later stage.
Recommend a restrained resolution. Slate covers a damaged partner, recognizes the corridor is lost and orders
the remaining flight to stand down. A pilot whose craft cannot withdraw can eject or request recovery if the
selected D3 tone allows it. Optional assistance follows the already secured corridor; refusing a new optional
rescue does not invalidate the player's earlier mission objectives or withhold Crown.
Author only the reachable outcome combinations. A recovered rival may acknowledge the player during the
return. A withdrawn rival can be reported clear of the route. A pilot unavailable under the selected tone
receives no contradictory flypast or dialogue. If Jonathan chooses permanent losses, the fallback roster and
final lines must follow that decision explicitly. The design needs a small outcome table, not a simulated
relationship system.

Crown layout and four useful functions
Use the proposed 800 by 800 by 220 arena around Crown. Keep a high observation route, a middle attack
circuit and lower cover with measured openings. At least two approaches should reach the core during an
opening without crossing an impossible turn or an invisible collision surface. Label the four vanes through their
shape, moving parts and short functional target text. A player should recognize the change caused by
destroying one.
Begin with the following proposed functions and consequences. Exact damage and firing intervals follow
measured spatial combat. Preserve a useful approach for the starter pair, and allow companions to attack a
marked vane only through their actual aim, line of sight and travel limits.




                                                                                                     Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 7>

FOXLIKE PHASE 07



 Vane                What it does while intact                     What disabling it changes

                                                                   Gun mounts fail visibly and that firing
                     Threatens the high crossing with a forecast
 Upper battery                                                     contribution ends, opening a safer observation
                     firing sweep.
                                                                   and attack route.

                     Cycles protection with a clear warning and    The field loses power and its moving assembly
 Core shield
                     exposed interval.                             remains open, allowing sustained core attacks.

                     Launches a finite reserve through a visible   Cancels groups still inside the reserve; aircraft
 Pursuit launcher
                     bay.                                          already launched remain real opponents.

                                                                   Stops new fronts and visibly powers down the
                     Forecasts dangerous regions across
 Storm control                                                     source, widening route choice without altering
                     selected approach routes.
                                                                   steering.



Core opportunities and meaningful attack order
Start a core timing experiment with a 28-second cycle containing an eight-second exposed interval and a four-
second advance warning. The warning is part of the protected portion, so these values do not add to a longer
cycle. The rest covers protected time and visible closing motion. Core targetability must agree with the
authoritative shield state and the presented opening.
Allow an early core attack before every vane is disabled. A skilled player may accept upper fire, pursuit
pressure and weather to exploit that opening. Shield-first makes sustained damage possible; upper-battery-
first buys a safer high approach; launcher-first reduces the number of tasks competing for attention; storm-
first improves route reliability. Removing more components helps, but no hidden rule demands all four.
Give the launcher a provisional reserve of three pairs, with at most one pair from that reserve active at once.
Spawn through a real bay route and count those pilots against the encounter budget. A slow player should not
face infinite replacements for learning the core timing. A destroyed launcher cannot erase aircraft already
pursuing the squadron.
Use two or three well-executed core passes as an initial damage-tuning question, not a minimum pass counter.
Measure the result with ordinary weapons, different companion pairs and partial ammunition. If shield-first
dominates every trial, examine exposure, routes and competing pressure before simply raising vane health.
Ask players which removal helped and whether the change was visible.

Fortress failure and checkpointed escape
Crown progresses from active defense to confirmed core defeat, power loss, structural failure, escape and
settled destruction. Component states determine which mounts fold, which vane hangs damaged and which
bays lose power. They may alter visible failure details and available side routes. Every legal victory state retains
a reachable main escape. Apply Phase 6's authored major-piece sequence rather than adding a general rigid-
body destruction simulation.
Commit the boss victory once under Phase 3's settlement rules. Prepare an escape checkpoint with a validated
entry pose, fixed wreck sequence, preserved player and companion condition, and the already defeated
Crown. Live flight continues through a visible power-loss interval into that entry. Restarting after an escape


                                                                                                        Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 7>

FOXLIKE PHASE 07


failure uses the authored checkpoint; it never asks the player to defeat Crown again. Resolve same-tick player
loss using the established settlement order before constructing the checkpoint. Its starting condition must be
playable, and a later death cannot overwrite the committed escape state.
Time the initial power-loss interval from the longest legal route to the escape entry, including turning and
recognition, with zero boost. Do not choose it from a cinematic duration. Stop new fortress attacks when the
corresponding system loses authority. Existing projectiles and departing pursuit craft follow an explicit settled
rule so the player cannot receive an unexplained hit during a presentation transition.
Major debris moves along declared paths with forecast danger and collision that agrees with visible geometry.
Small sparks and fragments remain cosmetic. A branch can close only after its warning has allowed a safe
alternative. Reduced shake, a paused presentation or a skipped noninteractive shot must preserve the same
debris positions, collision decisions and escape outcome.

Reassembly carrier recovery and the last playable minutes
Place a safe checkpoint after the destructive escape and before final recovery. Comet then receives a regroup
instruction and a clear route to Dragonfly. Let the player steer alongside the returning ships, see the repaired
carrier and approach a usable bay through the Phase 2 recovery rules. A blocked bay causes a readable abort
and another attempt. The ending should not introduce a new precision-landing examination.
Active companions join through lawful routes and show their real damage state. Withdrawn companions
already accounted for aboard Dragonfly can appear in a parked or recovery pose; they cannot suddenly
become intact airborne escorts. A damaged returning craft receives one bay assignment and one settled
arrival. Restore or skip must not duplicate that ship or place two craft in one occupied recovery slot.
The convoy tableau reads the settled optional rescue records. Use named or clearly recognizable saved traffic
where those identities already exist. Do not infer an unrecorded death from an omitted background model.
The rival acknowledgment uses the settled outcome, then leaves room for several quiet seconds of formation
flight before results. Crown is gone, the route is open and the flight has come home.

Reusable motion and asset delivery
Develop paired crossing attacks, synchronized breaks, covering withdrawal and a brief wing-rock
acknowledgment because the player needs to read cooperation. The portable asset provides local pose
samples, wing and thrust response, sockets and damaged variants. Foxlike's controller supplies actual routes
and collision. A paired motion must never teleport the second craft to make the composition attractive.
Crown adds vane articulation, progressive power loss, disabled gun mounts and ordered structural separation.
Recovery adds reassembly, damaged approach, abort, bay closure and parked poses. Camera framing, shake
and FOV remain separate. Each family needs a reset, interruption and finished state, stable part IDs and a
pinned source manifest. [S08] [S19]
Use the existing PBR flight lab for suitable pilot and recovery poses, and its capital-subsystem planning
destination for the fortress machinery. PR12 and PR13 remain unmerged branch implementations in the dated
audit. Phase 7 does not complete PBR's tactical recovery rules or merge those branches. Full, reduced and
skipped presentation must preserve PBR AP, cell, facing, combat result and gameplay RNG. Package 12
concerns city, bridge and utility destruction, so do not relabel it as a general capital-wreck system. [S10] [S12]
[S19]




                                                                                                    Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 7>

FOXLIKE PHASE 07



P7 1 Rival cooperation and storm routes
P7.1 Sol Medium. Produce the Stormbreak blockout, finite encounter roster, shared attack and cover
assignments, forecast fronts and outcome transitions. Dependencies are the earlier rival styles, common
defeat states, sensing, collision and campaign records. Build one complete cooperative sequence first, then
connect the remaining control routes.
Acceptance named Separated flight requires a human player to break cooperation with cover or objective
pressure and explain the resulting opening. Forecast escape requires a valid zero-boost route from each
sampled danger entry. Outcome continuity requires prior disables and absent rivals to produce the correct
roster, reward and final report. Record observations without claiming these checks have already passed.

P7 2 Crown functions and core choice
P7.2 Sol Medium. Produce four functional vanes, their readable damage states, the shield cycle, finite launcher
reserve and at least two core approaches. Depend on the Phase 5 component contract and P7.1's forecast
system. Build the core opportunity early so vane design can be judged by how it changes an actual attack.
Acceptance named Chosen order requires two different useful removal orders and a successful early-core
strategy without debug protection. Visible consequence requires each disabled vane to remove its declared
contribution. Persistent core state requires a checkpoint and reset to agree with shield, damage and reserve
state. Tune health only after route and warning evidence supports the encounter.

P7 3 Escape reassembly and recovery
P7.3 Sol Medium. Produce the fortress failure sequence, pre-collapse retry state, safe reassembly checkpoint
and playable carrier return. Consume Phase 6 major-wreck behavior and Phase 2 recovery. Confirm the main
route with exhausted boost before adding optional debris spectacle.
Acceptance named Victory preserved requires an intentional late crash to restart the escape with Crown still
defeated and no duplicate reward. Return accounted requires active, withdrawn and damaged companions to
occupy consistent states exactly once. Quiet finish requires completion with reduced camera effects and a
visible final interval in formation. Include a paired PBR presentation check for each newly exported pose
family.

P7 4 Conditional ending text and traffic
P7.4 Sol Light. Populate fixed captions, short rival acknowledgments, carrier status and traffic variants against
the settled outcome table. Dependencies are D3's tone and the implemented state identifiers from P7.1
through P7.3. Keep this package to bounded data and text authoring.
Acceptance named Correct acknowledgment requires each reachable outcome to select one coherent result
without naming a missing pilot or inventing a rescue. New branching logic, save semantics or recovery
behavior belongs in the relevant Sol Medium package rather than being hidden inside this authoring task.

Completion evidence and Phase 8 handoff
Deliver reviewable Stormbreak and Crown missions, their checkpoint fixtures, the reachable outcome table,
asset manifests and a concise list of unresolved issues. Required evidence includes an unassisted Standard
completion, an intentional escape failure and retry, starter and alternative companion approaches, two
meaningful vane orders, and the return with reduced camera motion. Capture at least one missing-rival case
and one damaged-companion recovery.


                                                                                                    Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 7>

FOXLIKE PHASE 07


Automate the finite state risks: reward settlement, forbidden rival reappearance, checkpoint restoration and
major-piece collision state. Human recordings establish whether the counterplay, core choice and ending are
understandable. An arranged animation capture establishes only the pose shown. Phase 8 receives those
distinctions and the exact tested build, rather than a bare assertion count.

Director choices and revision record
D3 remains the consequential local choice. Jonathan should select conciliatory, restrained or severe rival
resolution before final survival variants and dialogue are locked. Recommend restrained recognition and
possible recovery. Consume the settled D1 controls and D4 emergency policy; do not alter player engine
handling for the finale without that earlier decision.
This version expands parent proposals A5 and A6 for rivals and campaign, A7 for reusable assets and A8 for
production. The parent retains H1 through H8 and their original provenance. H9 records the human request for
eight separate detailed phase documents. These elaborations remain AI-origin planning for director Jonathan
Sanders. Version 1.0, 23 October 2026, creates this Phase 7 companion; it reports no gameplay
implementation or new test results. [S19]

Sources and related handoffs
The source links identify the evidence behind the baseline. The other phase documents describe proposed
work and should be read with the parent campaign handoff.
S01 Foxlike source baseline and README at inspected commit
S05 Existing flight controller boss damage and campaign flow
S08 Foxlike asset provenance and import notes
S10 PBR flight lab on the inspected unmerged PR12 branch
S12 Existing PBR campaign packages and their separate responsibilities
S19 Foxlike campaign planning revision 2.0




                                                                                                  Planning 1.0 | 7
