# Supplied guide: Foxlike_Phase_06_Carrier_Continuity_and_Emergency_Flight.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_69335c1b3ddc819198c961c6a47564df/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 8>

FOXLIKE PHASE 06




Foxlike Phase 6
Carrier continuity and emergency flight
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 6 turns the campaign's separate victories into a visible recovery. Cinder's repair parts arrive at Dragonfly,
the already developed Anchorage operation installs and protects them, and the fleet departs through the
route the player has cleared. The falling yard then asks COMET to read a damaged industrial vessel in motion,
stop its dangerous spin and divert its wreck away from an inhabited approach. The player gets an emergency
with understandable causes, useful companion choices and a short retry after each major intervention. This
document expands P6.1 to P6.4 as proposed work within the parent campaign. It reuses Phase 2's carrier
operation and Phase 5's component states. It keeps Dragonfly's authored drive overstrain distinct from
preventable damage, and specifies a bounded sequence of major wreck states rather than a general
destruction simulation.

The playable result and phase boundary
The player should understand why Anchorage happens, see what its success repairs and recognize the fleet's
next problem. The campaign now has an opening, a major victory at Sovereign and a complete recovery
movement. Anchorage remains the 15-to-18-minute carrier-defense operation developed in Phase 2. The
falling yard adds a proposed 12-to-15-minute emergency. Neither target is a measured duration. [S19]
This phase owns campaign continuity into the existing slice, the falling vessel's component-to-motion rules,
major wreck collision and checkpoint restoration, and the corrected aftermath reports. It consumes
established companion assignments, rival outcomes, carrier recovery and world flight. Phase 7 owns
Stormbreak, Crown and the final playable return. Do not add another carrier controller, another repair
economy or a new player engine-failure system to complete this phase.

Source baseline and proposal status
The October 23, 2026 audit examined Foxlike commit 84e9d31428e15d1a5271eddc18dac7d4fe0d5782.
Anchorage already has an arena, carrier health, radar and a boundary turnaround. The carrier model has
sliding door and tail presentation, but the source does not establish the expanded recovery operation,
persistent repair chain or The falling yard. Most boss damage hides the affected weak point, and boss death
produces generic bursts before removal. Authored major wreck motion remains proposed work. [S01] [S05]
[S08]
Phase 2 and Phase 5 in this document are development dependencies, not claims that their proposed work has
already shipped. Their acceptance evidence must exist before integrating the full continuity. PBR's inspected
PR12 and PR13 remain unmerged branch implementations. The PBR carrier deployment is presentation around
fixed tactical roots; it is not a completed tactical carrier or recovery actor. Reuse here supplies poses and parts
while the separate game retains its own rules. [S10] [S20]




                                                                                                    Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 8>

FOXLIKE PHASE 06



Incoming facts and carrier condition
Read the stable mission results from Phase 3. Terminus records that the blockade command was defeated and
Dragonfly overstrained its drive during extraction. Cinder records that the required replacement parts were
secured. Those are different facts from hull damage, a disabled bay, lost optional cargo, companion withdrawal
or a rival's outcome. Preserve each cause so the briefing can explain it. [S19]
Recommend carrying authored condition categories between sorties while the visible transition refit
establishes Phase 2's validated carrier-entry profile. This avoids importing an arbitrary near-zero hull value into
a mission balanced for a fresh defense. Preserve scars, unavailable optional support and earned damage
credit. The player sees hull stabilization before launch, and the required drive repair remains unfinished. If raw
hull health is retained instead, every legal incoming value needs a proven completion route before that
alternative is adopted.

 Incoming fact                 Meaning in Anchorage                       Protection against a broken campaign

                                                                          It never counts as a failed hull-defense
                               The primary drive needs Cinder's part
 Authored drive overstrain                                                objective or an avoidable player
                               and a protected installation.
                                                                          mistake.

                                                                          Ordinary campaign entry requires
                               A visible repair transport carries the
 Required parts secured                                                   settled Cinder success; replay uses an
                               replacement into the operation.
                                                                          explicit noncampaign fixture.

                               Select a repair approach, visible scars    Transition stabilization leaves a viable
 Preventable carrier damage
                               and any agreed support limitation.         primary repair and departure route.

                                                                          They cannot remove the only required
 Optional losses and           Change traffic, brief acknowledgments
                                                                          part, revive a withdrawn pilot or lock
 recoveries                    and bounded support opportunities.
                                                                          the next mission.



A continuous player walkthrough
The player finishes Cinder with the required cargo intact but loses an optional escort. The next briefing shows
the repair transport alongside Dragonfly. A scorched drive pod is clearly the extraction overstrain; patched
armor reflects the earlier damage record. With Latch and Pike selected, COMET takes the lower route around
the carrier while Pike pressures Harrow's exposed weapon. Latch covers the repair transport's attainable
approach.
Rook offers a chase away from the bay. The player refuses it and removes the bomber threatening the
transfer. When a bay door is damaged, the transport holds outside the danger region and the mission marks
the alternate approach already authored in Phase 2. The player clears it, the cargo latches and the installation
continues. A support craft returns damaged, giving the recovery system a visible job even if both selected
companions are healthy. The drive restarts and Dragonfly leaves. Its condition report now says the required
repair is complete.
In The falling yard, the player climbs to inspect the industrial hull, then dives toward the exposed overspeed
thruster. Disabling it stops the roll that was sweeping the upper route. The next intervention exposes a lower
stabilizer. COMET arrives too late for its first safe opening, brakes behind a structural brace and waits for the


                                                                                                      Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 8>

FOXLIKE PHASE 06


next announced cycle. The missed interval costs an optional unoccupied cargo module, not an instant restart.
A later collision kills COMET during final separation. Retry begins from the last stabilized state, with the correct
removed components and remaining enemy screen. The player takes the wider escape route, diverts the hull
and sees the fleet passage it has preserved.

P6 1 Connect delivery repair and recovery
P6.1 Sol Medium. Integrate settled Cinder and Terminus facts into Phase 2's existing operation. Its outputs are
one incoming-condition adapter, conditional briefing and traffic selection, a repair progress record and settled
departure result. Use the same carrier bay, companion recovery and finite-force logic as the slice. A standalone
slice fixture and a sequential campaign entry must reach the same behavior when given equivalent incoming
facts.
Repair progresses through transport approaching, cargo latched, installation protected, function check and
departure ready. Each stage has a physical sign: a guided approach, a closed clamp, workers or repair
equipment at the drive, a controlled engine pulse and the cleared departure marker. Progress advances on the
agreed objective events. A clock can describe installation work, but it cannot silently fill while the essential
cargo remains outside the bay.
A damaged receiving bay changes the approach and may pause installation until the player clears a known
alternative. It cannot create an unannounced requirement for a companion already withdrawn. Guard
assignments use the inherited reachability test. If both companions have left the sortie, COMET can protect the
transport and finish the local threats personally. Keep Harrow and Rook's existing Phase 2 roles; continuity is
not a reason to add extra waves.
Acceptance named One repair chain requires the same required cargo to be accounted for through Cinder
settlement, Anchorage arrival, installation and departure. Acceptance named Optional loss stays optional
compares an intact support run with the worst permitted optional-loss run. Both must finish, with the
consequence visible. Acceptance named Recovery counted once checks a selected pilot withdrawing while the
authored support craft is also waiting, including a bay interruption and a checkpoint load.

Failure and repair without hidden forgiveness
If the essential repair transport is destroyed during Anchorage, the current operation fails and retries from the
appropriate authored checkpoint. It does not conjure replacement parts behind the camera. Lost optional
cargo can shorten a later support window or remove background escort traffic; it does not remove the repair
item that campaign completion requires. Show which cargo is critical before the player commits to defense.
A companion who withdraws stays out of that sortie unless the inherited recovery rules explicitly allow a
return. Carrier repair does not refill every combat resource without a visible refit boundary. If loading produces
missing Cinder completion or incompatible mission data, use the existing checkpoint-version fallback and
explain the resumed mission. Do not fabricate a successful cargo history.
After departure, settle required drive repair, remaining major damage, recovery outcomes and the route
opened exactly once. An old alarm must not continue into The falling yard because a visual effect was left
running. Replay can demonstrate an alternate outcome without replacing the campaign's settled history unless
the existing replay rules expressly permit that change.




                                                                                                      Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 8>

FOXLIKE PHASE 06



P6 2 The falling vessel as a readable problem
P6.2 Sol Medium. Assemble one damaged industrial vessel from the capital and ground asset families accepted
in Phase 5. Use the parent 760 by 760 by 200 arena candidate. A failing support-thruster system still carries
part of the vessel's weight; this is a slow assisted descent that the player can alter, not a claim of realistic
freefall lasting fifteen minutes. Choose its starting altitude and vertical drift so the projected path remains
physically inside the authored volume for the whole encounter.
Begin with a readable silhouette, a marked inhabited approach and a safe diversion zone. The player can climb
for an overview, cross below the hull to reach a protected component, or brake behind a brace while a pulse
passes. A newly safe route should appear after each useful intervention. The limited enemy screen interferes
with those approaches but does not become the entire mission. Use the existing active-pilot budget and finite
arrivals rather than infinitely replacing escorts.
The output is a component-to-motion sequence with declared entry conditions, hazard volume, next projected
movement and stable checkpoint pose for every major state. Start with slow roll around two to three degrees
per second and a bounded vertical drift around 0.1 to 0.15 units per second. These are blockout hypotheses.
Measure the swept extremities of the actual hull, and reduce motion if a useful route closes before a pilot can
read it.
Acceptance named Intervention matters requires the player to identify which motion stopped or which route
opened after each target. Acceptance named Read before commit requires the next movement and danger
region to be visible before firing at the component. An exciting camera cut cannot supply information that
disappears when secondary camera motion is reduced.

Component states and intervention order
Use a small authored sequence rather than calculating arbitrary structural collapse. The player acts on
thrusters and a jammed stabilizer already visible on the vessel. Components may take valid early damage when
genuinely exposed. Preserve that damage; do not restore health because the script expected a later shot. If a
release remains mechanically loaded, show that condition and execute its confirmed release once the
preceding load change permits it.

 Stable state              Player intervention                     Motion and checkpoint consequence

                                                                   The dangerous spin arrests into a known
                           Disable the overspeed thruster after
 Unstable approach                                                 attitude. Save the first stabilized boundary
                           reading its plume and sweep.
                                                                   with the thruster disabled.

                                                                   A slow bounded roll exposes the lower
                           Disable the exposed counter-trim unit
 Spin arrested                                                     stabilizer and opens a new route beneath the
                           while managing the enemy screen.
                                                                   hull. Save the next stabilized boundary.

                                                                   The stabilizer deploys and the projected path
 Lower mechanism           Release the jammed stabilizer during
                                                                   shifts toward the diversion zone. Save the
 accessible                its readable safe approach.
                                                                   settled intervention before final separation.




                                                                                                    Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 8>

FOXLIKE PHASE 06



 Stable state              Player intervention                     Motion and checkpoint consequence

                                                                   Major pieces follow declared paths and settle
                           Leave through one of the marked         into the selected safe wreck variant. Settle
 Diversion committed
                           clearance routes.                       the mission only after the required clearance
                                                                   condition.



Openings altitude and credible warning time
Treat height as access and exposure. An upper pass gives an overview but crosses the widest roll sweep. A
lower route hides COMET from some defenders but needs clearance beneath moving machinery. Place the
next target and its approach marker on both the visible structure and the selected-target display. Above or
below indicators and a stable structural reference must remain readable with sound muted.
Start a local pulse experiment with a six-second warning and an escape offset no greater than roughly 40 units.
For major separation, start with twelve seconds and a safe route about 140 units away. At the inherited 22-
unit brake speed, that distance alone takes 6.36 seconds; a 180-degree turn at 1.12 radians per second adds
about 2.80 seconds. Reading and acquisition need margin too. Validate the full three-dimensional route rather
than accepting these sums as proof. [S04] [S19]
A missed opening gets another announced cycle before failure. Begin with a ten-second accessible interval
within a roughly 25-second local cycle, then tune from actual approach recordings. The first miss can sacrifice
an unoccupied cargo section; further misses may exhaust a clearly displayed intervention deadline. State the
cost and last chance before they occur. Any deadline must remain attainable with depleted boost, the starter
pair or both companions withdrawn.

P6 3 Major wreck collision and checkpoint restoration
P6.3 Sol Medium. Integrate the major wreck states with authoritative collision, escape routes and authored
checkpoint snapshots. Keep the set small: the main hull and a few identified solid sections affect flight, while
sparks and small fragments remain cosmetic. Declare which parts become solid before separation. Never turn
an unmarked decorative fragment into a lethal obstacle because an effects setting changed.
The same state and sampled progression drive the large part's visible pose, collision pose and hazard forecast.
A component cannot complete its physical separation while its collider remains in the old location. Conversely,
a new collider cannot appear around a player who occupied clear space without a prior swept danger region.
Reserve the escape corridors in the authored geometry and check their clearance with the actual aircraft and
maneuver envelopes.
Save only the accepted stable boundaries, using Phase 3's checkpoint format and version rules. Record
component condition, wreck variant, stabilized pose, remaining finite enemies, mission cost already incurred,
player and companion condition, ability resources and settlement state. Restoration chooses the documented
start of that stage; it does not reconstruct an arbitrary mid-roll frame from animation time.
Outputs are a compact wreck-state manifest, collision and hazard mapping, checkpoint adapters and a
repeatable emergency review scene. Acceptance named Same wreck outcome compares uninterrupted play, a
pause, an allowed presentation skip and checkpoint restoration from equivalent authoritative state.
Acceptance named Escape at reserve zero requires a route completed without boost, including a late



                                                                                                   Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 8>

FOXLIKE PHASE 06


intervention retry. These checks detect state disagreement; human play still decides whether the warning and
route are understandable.

Collision interruption and optional loss rules
Before a transition, assess the whole swept major-hull volume, including projecting corners and detached
sections. Safety routes must exist for the player's current reachable region, not merely for the intended
recording position. If a transition needs an additional short hold while the warning completes, author that hold
explicitly and include it in the forecast. Do not teleport the player out, erase an incoming shot or add invisible
invulnerability to save the sequence.
Pausing freezes authoritative vessel motion, projectiles, deadlines and AI together. Optional camera playback
may be skipped only at established presentation boundaries; it cannot skip an interactive escape or choose a
different wreck variant. Reduced effects omit shake, debris density or camera roll while retaining targets,
collision and timing. [S19]
Optional costs settle once at their state transition. Retrying a later checkpoint cannot lose the same cargo
again. Cosmetic random particles use a separate presentation sequence and cannot affect the chosen major
wreck path. If the player fails the last safe intervention, the failure message identifies the missed objective and
resumes its short checkpoint. It must not replay Anchorage.

P6 4 Aftermath and carrier status reports
P6.4 Sol Light. Once P6.1's condition mapping is settled, write the corrected Terminus aftermath and the fixed
carrier status reports. Replace the existing final-sounding sky-clear line with the blockade success, the
extraction overstrain and the next repair objective. The text must distinguish 'drive regulator overstrained
during extraction' from 'port armor damaged under attack.' The second statement appears only when its
condition is true. [S05]
Provide short lines for parts secured, cargo held, alternate bay approach, installation complete, drive test
passed, departure ready and wreck diverted. Essential status also appears as persistent readable objective text
when chatter is interrupted. Keep COMET and the established crew voices; do not introduce a new named
engineer just to deliver a state label.
Acceptance named Report matches world checks every conditional line against the visible state and saved fact.
A writer may populate agreed variants as Sol Light. Deciding a new repair branch or failure rule returns to P6.1
or P6.2 as Sol Medium.

Reusable motion and the separate PBR contract
The useful new families are asymmetric thrust, power loss, arresting a roll, stabilizer release, major section
separation, interrupted approach, repaired engine restart and damaged bay recovery. Each needs explicit state
inputs, stable part IDs, socket and pivot limits, source version, reset, cancel and settled poses. Root motion
remains a Foxlike mission or vehicle decision. Camera shake and framing remain optional presentation. [S08]
[S19]
A paired PBR preview should demonstrate the same local part sequence while its accepted tactical outcome
remains unchanged under full, reduced and skipped presentation. The inspected PBR deployment already
illustrates that separation, but future recovery eligibility, occupied cells and capital damage belong to its
unfinished packages 5 and 7. This phase does not complete them. Capital failure assets map to package 5; only



                                                                                                     Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 8>

FOXLIKE PHASE 06


specifically adapted city, bridge or utility ruin variants map to package 12. The PR13 walker remains a source of
parts and motion, not a transferable ground-combat system. [S10] [S11] [S12] [S20]

Tuning experiments and completion evidence
Measure the danger that remains after Phase 2 and Phase 5 acceptance. Begin with the following experiments
and change one relevant variable at a time. The aim is to prove that the player can predict a moving threat and
make a useful choice, not to maximize the number of checks.

 Experiment              Starting comparison                      Evidence required

                         Intact optional support versus the       Both finish using the same critical repair item;
 Repair continuity
                         worst permitted optional losses.         differences are visible and no route is locked.

                                                                  Recorded approaches show when the target
                         Two versus three degrees per second,
 Vessel roll                                                      and escape become readable, including lower
                         with identical geometry and screen.
                                                                  routes.

                         Full boost reserve versus empty          An actual reachable exit exists in both runs
 Warning and fuel        reserve at the same danger               without camera assistance or collision
                         announcement.                            exceptions.

                         Latch and Glint versus Pike and          Pairs change the easiest approach, while solo
 Companion choice
                         Ember; repeat with both withdrawn.       completion remains possible.

                                                                  The same confirmed component state yields
                         Full play, pause, checkpoint retry and
 State restoration                                                the same solid wreck, loss record and mission
                         reduced presentation.
                                                                  result.



Completion and handoff to the final movement
Complete the phase with one continuous Cinder-result-to-Anchorage run, one uninterrupted Standard falling-
yard run and one intentional late failure followed by a correct retry. Record a lower approach, a missed
opening recovered on the next cycle, an alternate companion strategy and reduced-camera-motion play.
Distinguish arranged animation captures, automated state checks and human play. The prior source audit
contains no new evidence for these missions.
Automated checks should target real remaining risks: duplicate cargo or rewards, stale bay reservations,
incorrect component restoration, new collider overlap, gameplay state changing with presentation and frame-
rate dependence in sampled motion. Compare 20, 60 and 120 rendered frames per second under the same
simulation rules where that resolves motion disagreement. Do not treat a render count as evidence that the
mission is enjoyable.
Phase 7 receives a departure-ready Dragonfly with its authored repair completed, optional major-damage and
rescue records, settled rival outcomes, the chosen safe wreck variant and the fleet passage opened. A later
view of the diverted hull should make the preserved route recognizable. Keep those facts in the existing
campaign record and update the accepted asset manifests. The next phase can stage Stormbreak without
inventing another reason that the carrier cannot leave.



                                                                                                      Planning 1.0 | 7

<PARSED TEXT FOR PAGE: 8 / 8>

FOXLIKE PHASE 06



Director choices and authorship note
The main local choice is carrier condition carryover. Recommend visible between-sortie stabilization with
categorical consequences and Phase 2's validated entry profile. If Jonathan wants exact raw hull persistence,
schedule the extra entry-condition proof before accepting that rule. Parent decision D4 remains open: this first
emergency places the physical failure on supported ships, preserving COMET's familiar flight controls. Impaired
player-engine handling needs its own approved experiment.
This phase companion is version 1.0, dated October 23, 2026, directed by Jonathan Sanders and drafted with
Channel Hideo. It preserves the parent H1 to H8 register and records the separate-document request as H9.
Repair staging, wreck states, numeric trials and acceptance criteria are AI-origin elaboration of A6 to A8. They
remain proposals. No gameplay code, new human playtest or PBR implementation completion is claimed.
[S19]

Sources and related handoffs
The source links identify the evidence behind the baseline. The other phase documents describe proposed
work and should be read with the parent campaign handoff.
S01 Foxlike source baseline inspected on October 23 2026
S04 Foxlike arena speed turning and boundary baseline
S05 Foxlike controller carrier health boss damage and victory reports
S08 Foxlike carrier and asset import provenance
S10 PBR Foxlike flight lab on the inspected open draft PR12
S11 PBR walker rig and gait preview on the inspected open draft PR13
S12 Existing PBR capital recovery city and ground campaign packages
S19 Parent Foxlike campaign plan revision 2 dated October 23 2026
S20 PBR carrier deployment presentation and tactical authority at the inspected snapshot




                                                                                                   Planning 1.0 | 8
