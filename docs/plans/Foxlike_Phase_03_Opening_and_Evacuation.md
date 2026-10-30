# Supplied guide: Foxlike_Phase_03_Opening_and_Evacuation.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_8e10470349c88191a664afcc0014deaa/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 6>

FOXLIKE PHASE 03




Foxlike Phase 3 The opening and evacuation
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 3 turns the proven Anchorage flight and companion systems into the campaign's beginning. Viridia
teaches useful three-dimensional flying while the player opens a harbor evacuation lane and dismantles
Warden. The last ferry then asks the player to protect the people using that opening, choosing when to scout
ahead, intercept a high bomber or leave a companion near the convoy. Pike becomes an earned alternative
after Viridia, while Latch and Glint remain a viable pair throughout. The phase also establishes stable mission
identities and migrates existing progress before inserting the new operation. Its completion is a connected,
understandable two-mission journey with meaningful success and failure, reliable checkpoints and preserved
player records. All expanded encounters, values and implementation choices in this document remain
proposals under the parent campaign plan. The task authorizes planning; it does not establish that these
changes have been implemented.

Scope and inherited evidence
The inspected source already contains Viridia and Warden, five companions, two selection slots, three
formations, missile ammunition, pickups, separate boss weapon health, mission retries and persistent records.
Pike currently unlocks from the original Viridia stage index. Warden's Standard baseline is a 260-health core
and two 65-health cannons; the core takes eight percent damage until its systems are disabled. These are
inherited audit findings, not fresh playtest results or approved balance for a longer arena mission. [S01], [S02],
[S03], [S04]
Phase 3 owns the harbor encounter, the convoy operation, their progression relationship and the migration
needed to insert missions safely. It consumes Phase 2's bounded world-space flight, companion assignments,
solid cover, carrier operation, basic rival defeat and recovery, and checkpoint foundation. It does not own a
new flight controller, a trading economy, a procedural campaign or a selectable legacy campaign. Preserve the
old compact build as a tagged source snapshot and retain its earned records.
The parent targets are ten to twelve minutes for Viridia and twelve to fifteen for The last ferry. Those are
successful-play pacing aims. A shorter encounter with sustained useful decisions is preferable to padding the
route with waiting or repeated waves. New writing and encounter rules below retain AI origin until the director
adopts them.

The connected player journey
A new player chooses Latch and Glint, receives a short briefing showing Warden and the threatened crossing,
and launches from Dragonfly. Ordinary steering, boost, brake and weapon controls are available immediately.
A brief rail approach may establish the coast, but it must be skippable on retry and must not withhold normal
free-flight controls behind a tutorial checklist.
The harbor reveals its problem through movement. A transport waits behind the sea wall; Warden's cannon
sweeps the exposed crossing. The player can approach low through cover, climb to see the upper gun, or make
a middle-height broadside pass. Removing the covering cannon lets the first transport move. That visible
change explains why the target mattered before the player finishes the frigate.



                                                                                                    Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 6>

FOXLIKE PHASE 03


After Warden falls, the debrief confirms the lane is open and introduces Pike's missile role through the existing
loadout screen. The second mission follows the convoy through two linked coastal sectors. The player now
decides whether to scout the next crossing, remain near a damaged ship or intercept a bomber above the
route. Rook offers an attractive chase away from that work. The final rendezvous shows which optional
transports arrived and gives the squadron a clear reason to follow the enemy relay toward Aurora.

P3 1 The harbor and Warden
P3.1 is Sol Medium. Deliver an approximately 520-by-520-by-120-unit harbor blockout with Warden, one
required crossing, recognisable upper and lower approaches, and enough solid scenery to demonstrate line-of-
sight breaks. The dimensions inherit the parent plan as provisional game units. They do not convert a Star Fox
arena into real metres. Measure the usable fighting volume after reserving the perimeter turnaround belt.
Place the sea wall, warehouse group and frigate so each route offers a different exposure. The low route
interrupts the upper gun's view but hides its mounting point from the player. The higher route reveals that
point and the next escape direction but leaves the aircraft visible to interceptors. The middle route offers a
shorter attack pass while crossing a broad weapon arc. Avoid a decorative obstacle layout that gives the
impression of shelter while projectiles pass through it.
The frigate should face and track through declared mount limits. Its first cannon teaches one clear relationship
between a warning, an exposed attack lane and a safe alternative. Give that mount an identifiable damaged
shape after destruction. Stop its firing contribution when the gameplay state changes; do not rely on hiding a
glow to communicate the entire result. The second cannon can continue to cover another approach while the
open crossing remains useful.
Keep the existing core and cannon health values as a comparison build, then test whether the new approach
lengths and firing windows make the encounter too short or too repetitive. Do not multiply health merely to
reach the duration target. Increase useful movement or vary the frigate's readable attack sequence before
adding another minute of firing at an unchanged object.
The package output is a complete harbor mission with launch, first crossing, frigate defeat, checkpoint retry
and a result. Its dependencies are the shared flight and collision rules from Phase 1 and companion/objective
systems from Phase 2. The substantial player-facing change is that the route the player clears becomes visibly
usable.

Warden state and checkpoint rules
Use explicit mission states: arrival, crossing threatened, lane opened, frigate defeated, result committed. Track
each cannon separately from the hull and separately from the crossing flag. The lane opens when its named
threatening mount is disabled and the authored crossing is free of an active immediate hazard. It must not
close again because an unrelated reinforcement spawns.
Create the boss checkpoint after the first safe crossing is established. Record which cannon is disabled,
Warden's relevant condition, the remaining finite encounter groups, player and companion condition, and the
checkpoint version. Retry restores that state once. It does not respawn the disabled cannon, repeat its score
award or place the player inside its wreck.
Failure may come from player defeat or a clearly announced loss of the required route objective. Optional
transport damage is not an automatic mission failure. Keep the whole-mission restart available if the saved
boss position is uncomfortable. Every authored checkpoint must leave a viable completion with the resources
it records, including an empty boost reserve.

                                                                                                    Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 6>

FOXLIKE PHASE 03


On success, commit Viridia completion and the Pike unlock together. Warden and the open corridor determine
required success. An optional straggler outside the route must not hold the mission in an unfinished state.

P3 2 The convoy operation
P3.2 is Sol Medium. Build The last ferry using two linked sectors of roughly 600 by 480 by 140 units, joined by a
visible holding area. The player escorts one required lead transport, with optional additional transports
contributing to the result and later fleet traffic. Keep the required ship easy to identify through shape, marker
and radio description rather than colour alone.
The convoy follows authored route segments with clear shelter, crossing and arrival states. It waits at a shelter
when the next crossing remains blocked, departs after that threat is resolved, and continues to the next
holding point. Enemy arrivals come from a finite operation budget. Waiting cannot generate unlimited
attackers or create an endless supply of score and pickups.
Threats must become answerable before they become lethal. A bomber first reaches an observable upper
staging route, then aligns, then releases. The player can climb to intercept, order a companion to attack it or
keep a guard near the transport and meet the final run. The timing has to include the actual turn, travel,
weapon acquisition and firing opportunity from a reasonable defended position. Do not assume continuous
boost across the entire sector.
Make scouting useful without making it compulsory. A player who flies ahead can remove a battery before the
convoy arrives; a player who stays nearby can protect the crossing through interception. Cover positions and
threat budgets should make both approaches workable. The starter pair must succeed without Pike's missiles,
and a guard assignment must not guarantee survival against every attack.
Optional transports may arrive damaged, fall behind or be lost after a clearly warned and avoidable failure.
Their loss changes the debrief and later visible traffic. It cannot remove an essential companion unlock or
strand the main campaign. The required transport's destruction causes a mission failure with a concrete
explanation of the attack that reached it.
The package output includes convoy route authoring, threat ownership, safe holding points, optional outcome
recording, Rook's objective bait and a final rendezvous. It consumes Phase 2's attack/protect/regroup
commands and basic rival state. Reuse the existing coastal kit and transport or carrier-derived geometry
before requesting a new environment family.

Rook and useful companion choices
Rook enters the story by attacking the convoy during The last ferry. The bait is visible: Rook crosses the player's
view, turns toward a tempting low pursuit route, then tries to return to an exposed transport or companion.
Refusing the chase should leave Rook badly placed for the objective. The pilot cannot instantly switch back
with a hidden speed or turn advantage.
Use Phase 2's rival defeat/recovery state immediately. A disabled Rook counts as a win, receives a visible
withdrawal or ejection outcome and remains absent for the rest of that encounter. A later appearance
requires the campaign to establish recovery and a serviceable hull. Phase 4 develops Shrike; it is not a
prerequisite for making Rook defeatable here.
Latch can cover a committed crossing or intercept a nearby valid shot. Glint removes a close pursuer more
efficiently when the player creates a steady firing opportunity. Pike pressures a bomber from a real launch
corridor. The debrief should name the useful contribution that occurred rather than award generic praise.


                                                                                                    Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 6>

FOXLIKE PHASE 03


Preserve individual cooldowns and ammunition ownership. An assignment changes intent, not the physical
rules or the cost of using an ability.

A representative success and a recoverable failure
In a successful convoy run, the player leaves Glint near the lead transport and climbs early toward the
bomber's staging point. Rook offers a low pass across the camera. The player ignores it, forces the bomber to
break, then returns toward the crossing while Glint occupies the close fighter. The convoy moves because the
immediate route threat is removed, not because a hidden timer finishes.
In a failed run, the player follows Rook too far and misses the bomber's announced alignment. The transport
takes a visible hit and reports engine damage. The next shelter remains reachable, but the slower ship gives
the player a harder escort interval. A second unresolved attack may destroy the required ship. The failure
screen identifies that sequence and offers the last valid checkpoint or a full mission restart.
Retry should restore the authored route state and remaining threat groups, with no duplicated optional
survivors or pickups. If the last checkpoint records an already damaged transport, the player sees that
condition before resuming. A state that is mathematically doomed must not be offered as a normal retry.
Either author enough shelter and warning to recover or place the checkpoint earlier.
The player who instead scouts ahead should encounter the same finite threats from another angle. Do not
spawn a fresh unavoidable attack behind the convoy simply to counter the chosen strategy. The mission's
challenge comes from allocation and flying, not from nullifying whichever plan the player adopts.

P3 3 Stable mission identities and migration
P3.3 is Sol Medium and must finish before the new operation enters the live mission order. The current source
uses six indexed stage definitions, numeric completion entries and record keys containing stage index and
difficulty. Roster availability reads the original completion gates. These source details explain why merely
inserting a row would corrupt meaning. [S01], [S02]
Introduce stable identities for the expanded campaign, using the parent examples such as viridia_blockade and
viridia_ferry. Maintain an explicit legacy mapping: old zero means Viridia, one Aurora, two Terminus, three
Cinder, four Anchorage and five Tempest. Preserve the identity of every old score and completion even when
its displayed campaign position changes.
Migrate previously earned Pike, Ember and Bastion access from their original achievements. Do not require an
existing player to repeat Viridia or complete the newly inserted ferry to keep Pike. Preserve difficulty records,
sound preference and the selected valid companion pair. Newly added operations can be presented as
available new content where the old progress logically reaches them, without pretending they were already
completed.
Keep progression access separate from historical completion. A player who previously finished all six missions
retains those completions and can reach the expanded content, but the record must not invent a successful
convoy rescue or courier capture. For later story conditions that an old save cannot contain, use an explicit
neutral migration state rather than silently choosing the best or worst outcome.
Validate the complete replacement state before committing it. A malformed save should retain the project's
recoverable default behavior and a clear recovery path. A valid old save must not be discarded because it lacks
new optional fields. Keep a recoverable original until the new state is safely written; repeat loading or
migration must converge on the same result.


                                                                                                   Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 6>

FOXLIKE PHASE 03


The package output is a documented identity map, versioned campaign data, migration behavior and actual
old-save verification. It also establishes attempt settlement so a repeated result callback cannot pay the same
reward twice. This is necessary player continuity work, not a reason to redesign the whole save system.

Mission results and replay behavior
Separate an in-progress attempt, committed campaign outcomes and best replay records. A failed attempt
does not mark a required objective complete. A completed replay may improve its score record without
rewriting the active campaign's convoy survivors behind the player's back. If the director later wants replay to
replace story outcomes, that requires an explicit policy and interface.
The parent plan calls for authored checkpoint boundaries rather than arbitrary mid-animation saves. Phase 3
should use that contract consistently. Save the logical objective and resource state, then reconstruct vehicle
presentation on load. A transport's damaged engine state is restored because the damage record says so, not
because a partly completed animation happened to be visible.
An interrupted transition between Viridia's victory and its debrief must still grant one completion and one Pike
unlock. Returning to the menu, resuming and replaying cannot duplicate a rescued transport in later traffic.
Switching difficulty changes the record category while preserving the agreed campaign access rules.
Keep the migration tests focused on risks: an old early-game save, a Terminus-clear save with Bastion, an all-
six-clear save, a valid save with an unusual loadout, a malformed record and repeated migration. Compare the
actual stored identities and earned access, not just a successful load message.

P3 4 Briefings prompts and authored data
P3.4 is Sol Light after the objective states and mission identities are settled. Author briefing text, fixed arrival
markers, unlock descriptions and debrief variants against those existing states. If a requested line implies a
new route condition or mechanic, return that requirement to the responsible Sol Medium package instead of
hiding it inside a text task.
Viridia's briefing needs three facts: the crossing is blocked, Warden's named mount covers it, and the squadron
must bring the evacuation ships through. The ferry briefing explains the required transport, optional
passengers and the next shelter. The player should know what to protect and what an incoming warning refers
to before the first attack.
Keep necessary warnings available when sound is muted and optional chatter is cut. A bomber alignment,
convoy departure and transport damage report need short visible feedback. Banter can express Rook's
personality between those messages. Do not let a longer taunt replace a current objective warning.
After Viridia, explain Pike through the loadout action the player can take now. After the ferry, show required
success, optional survivors and notable companion contributions without burying them under kill statistics.
The output includes a state-to-message table for implementation, but the player sees ordinary briefings and
results rather than internal state labels.

Reuse and presentation boundaries
Phase 3 develops carrier launch alignment, fighter bank-to-dive transitions, turret tracking and recoil, disabled
mount poses, transport banking, formation compression, engine sputter and cover handoff. These motions
belong to the portable vehicle presentation contract. Foxlike still owns their actual movement, collision,
health, scoring and objective consequences.


                                                                                                       Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 6>

FOXLIKE PHASE 03


A damaged turret should have an intact, firing, disabled and resettable presentation. A transport needs
cruising, turning, damaged propulsion and arrival poses. Record model axes, sockets, dimensions, part IDs and
reset behavior using the parent contract. Reuse the existing PBR flight lab for pose inspection; do not claim a
convoy animation implements PBR escort rules.
Camera choices remain separate. A slight framing change may help reveal a departing transport, but it cannot
take away essential steering during an attack or change whether a projectile hit. Full, reduced and skipped
nonessential presentation must settle the same objective result. Build the useful motions while the encounters
expose their purpose, rather than authoring a large unused animation catalogue.

Tuning experiments and completion evidence
Run a small set of decision-focused comparisons. In Viridia, compare low and high approaches using the same
cannon timing and ship limits. Measure time to identify the threatening mount, time from destruction to
transport movement, and how often the player collides while trying to use intended cover. A route that only
looks different has not met the spatial objective.
In the ferry, compare nearby guard play with advance scouting, first using Latch and Glint, then an available
pair containing Pike. Record warnings, attainable intercept time and actual damage to the required transport.
A loss is acceptable when the player knowingly leaves a threat unanswered. A loss while following a valid
marked defense with no feasible intercept is a design defect.
Completion requires a fresh player to finish the connected two-mission journey, understand why a cannon
mattered, change a companion after the unlock, and explain a convoy failure. Demonstrate a failed boss
attempt and retry, a failed escort attempt and retry, an optional transport loss that does not block progression,
and an early Rook defeat that persists correctly.
Verify migrated progress and a clean campaign separately. Preserve source and playback evidence for the
working revision, but do not substitute automated assertions for human observations of readability or
enjoyment. The handoff to Phase 4 includes the stable mission identity contract, outcome fields, checkpoint
reconstruction, convoy/transport motions and settled rival recovery behavior. Aurora may consume those
foundations without inventing a second progression system.

Provenance and revision history
Version 1.0 dated 23 October 2026 expands this phase from the Foxlike campaign handoff version 2. The user
requested separate detailed DOCX phase plans, recorded here as H9. The parent retains H1 to H8 and the A3
to A8 design proposals. New encounter details, numerical starting values and implementation choices in this
expansion remain AI-origin proposals. The request authorizes planning, not gameplay implementation or
publication. Source facts retain the dated audit and pinned revision cited below; no new human playtest is
claimed. [PARENT]

Sources and related handoffs
PARENT Foxlike campaign design and handoff version 2
S01 Foxlike six indexed mission definitions at the inherited audited commit
S02 Existing companion roster unlock gates and save normalization
S03 Existing flight combat boss damage progression and result behavior
S04 October 23 playtest resolutions and evidence limits
S05 Foxlike source provenance and inherited cast



                                                                                                   Planning 1.0 | 6
