# Supplied guide: Foxlike_Phase_05_Sovereign_and_Ground_Corridor.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_ad68321137208191bf8453293fdc6f15/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 7>

FOXLIKE PHASE 05




Foxlike Phase 5 Sovereign and the ground corridor
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 5 gives the campaign its major blockade victory and then changes the player's job. Terminus asks
COMET to dismantle Sovereign by choosing which working system to silence, using the space above and
beneath the hull while Slate coordinates the defenders. Cinder moves the player into Jackal, where cover,
limited hover fuel and readable ground threats determine how the repair convoy gets through. The two
missions form one consequence: Dragonfly overstrains its drive extracting the convoy from the collapsing
drydock, and Cinder secures its replacement parts. This document expands the parent campaign's P5.1 to P5.5
as proposed planning. It consumes the earlier flight, rival, companion and checkpoint contracts. It does not
implement either mission, adopt a new driving game, or treat the Project Barrel Roll walker preview as
completed ground combat.

The playable result and phase boundary
Terminus should feel like taking a defended machine apart through deliberate approaches. A bay attack
reduces future launch pressure; a drive attack changes the hull's movement and the next core opportunity; an
antenna attack weakens shared contact reports. The player should notice the consequence on the following
pass. Cinder then changes scale and rhythm. A three-yard industrial route asks the player to judge a crossing,
land safely, read a walker's planted stance and expose Iron Maw's mortar position.
The target remains 15 to 18 minutes for Terminus and 12 to 15 for Cinder, excluding retries. These are
proposed pacing targets from the parent, not measured play times. Completion includes a settled Terminus
result, Bastion unlocked by mission identity, Cinder's required parts delivery, and a valid handoff to Anchorage.
Phase 6 owns installation, carrier repair continuity and The falling yard. [S19]

What exists in the inspected source
The October 23, 2026 audit pins Foxlike to 84e9d31428e15d1a5271eddc18dac7d4fe0d5782. That Godot 4.7.2
project already contains Sovereign, Iron Maw, Jackal, multipart boss damage, companion equipment and
mission results. Boss death currently produces generic bursts and removes the model. The existing victory line
describes Sovereign's destruction as clearing Asterion's sky. A capital assault with working bays, staged hull
failure and the corrected aftermath is proposed work. [S01] [S05]
Jackal already has finite fuel, ascent, gravity and grounded recharge. Its current controller scrolls forward at
target speeds of 32 or 18 units per second, steers laterally within a local band, and uses vertical input for aim.
It does not provide free ground driving or a brake-to-stop action. Existing tracks and wheels are modeled,
while hover flames and small suspension movement provide initial presentation. Root travel, turning yards,
track synchronization and weapon-driven recoil need explicit adaptation. [S05] [S17] [S21]
PBR draft PR13 contains a two-leg rig and gait preview at d0e569cf5926cdfb048612794835ed2378d966c4. It
does not contain the Foxlike walker behavior proposed here. At the inspected snapshot, PR12 and PR13 are
unmerged branch implementations. This phase may pin the walker asset without adopting the branch's
unrelated campaign work. [S10] [S11]




                                                                                                     Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 7>

FOXLIKE PHASE 05



Inherited contracts and owned outputs
Phase 5 begins after the shared controller, sensing, obstacle collision, companion assignments, arena
maneuvers and rival outcomes have usable evidence. It uses Phase 3's stable mission IDs and checkpoint
settlement. It must not introduce a second flight controller to make Slate seem clever, or a second campaign
reward path for the two new mission results. [S19]

 Contract consumed                     Phase 5 responsibility

                                       Supply capital approach routes, air support assignments and declared
 Shared vehicle and pilot rules        walker limits. Keep flight sensing, energy, collision and companion
                                       reachability authoritative.

                                       Read Shrike's confirmed recovery before casting the high defender. Record
 Rival encounter record
                                       Slate's outcome through the common defeat and withdrawal states.

                                       Settle terminus_sovereign and cinder_corridor once. Preserve disabled
 Mission checkpoint and result
                                       systems and remaining finite enemy groups at authored retries.

                                       Output required drive overstrain, preventable damage separately, parts
 Carrier and asset contract
                                       secured, stable component IDs and deterministic failure poses for Phase 6.



A player journey through the two missions
COMET enters Terminus with Pike and Latch. The bay is launching a small reserve, the drive is preparing a turn
and the antenna is feeding Slate's wing with shared sightings. The player takes the low drydock route, marks
the drive for Pike and waits until the hull has turned enough to expose it. Latch covers the close approach.
Destroying the drive changes the next turn and lengthens the recovery window. The player sees the benefit
before receiving a score message.
A tempting chase after Shrike leaves the player high and outside the lance's best escape route. The charge
warning appears on the hull and the HUD. With little boost left, the player brakes and turns behind a dock
brace. The beam misses, but the delayed attack lets one launch group escape the bay. That group remains a
real problem. Destroying the bay afterward cancels only launches that have not occurred.
After the core fails, COMET clears the marked departure corridor while Dragonfly extracts the convoy. Its drive
flares, loses symmetry and enters a restricted operating state. The result credits the player's clean hull defense
separately. Cinder follows with Bastion newly available. In the first yard the player spends hover fuel too early
and drops onto a lower catch deck. The tank survives, recharges and takes the longer covered route. The
mistake costs time and a firing opportunity, not the whole mission. Later the player waits for a walker to brace,
forces its turn and crosses during recovery. The final yard checkpoint protects the Iron Maw fight from another
full route replay.

P5 1 Sovereign systems and escape
P5.1 Sol Medium. Build the complete Terminus encounter around a proposed 800 by 800 by 200 volume. Begin
with a low approach around 20 to 60 units above the floor, a hull and dock region around 70 to 120, and high
staging around 140 to 180. Fit those regions to measured hull and collision dimensions. Keep most



                                                                                                    Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 7>

FOXLIKE PHASE 05


engagements 70 to 180 units apart; the outer space gives pilots room to turn and recover. Place solid dock
structures where their silhouettes explain cover and leave at least two approaches to each essential target.
The first output is a component state map with a visible consequence for each disable. Intact, damaged and
disabled states drive weapons, motion and the model through the same confirmed event. The core uses
repeated, readable opportunities. As a provisional rule, disabling any one functional system permits a six-
second core opening during lance recovery. A disabled drive extends that window to eight seconds. Other
systems make the approach safer in different ways. The fight must remain winnable without removing every
part.
The second output is Slate's defense pattern. Slate coordinates an attacker and a covering aircraft at different
heights, yields an attack to protect a damaged partner, and obeys the inherited contact rules. Shrike occupies
the high role only after confirmed recovery from the courier encounter. Otherwise a regular pilot performs
that tactical job without impersonating Shrike or revoking the earlier defeat. Removing the antenna ends fresh
shared reports; it does not erase each pilot's own visible contacts or memory.
The third output is lance recovery, hull failure and an escape route. Start with six hostile pilots and a finite
reserve of eight, subject to the already profiled active-pilot ceiling. A bay disable can remove one unopened
group of four from that reserve. These are proposed tuning numbers. Acceptance named System consequence
requires two successful runs with different first targets and visibly different pressure. Acceptance named
Honest escape requires the escape at depleted boost, using the same collision and boundary rules as ordinary
flight.

 System                Readable state change                        Next player decision

                       Doors jam or lose power; the next
                                                                    Spend the quieter interval attacking the
 Launch bay            unlaunched group is canceled. Existing
                                                                    core or cover an exposed ally.
                       aircraft remain active.

                       Directional thrust changes; the next
                                                                    Use the altered underside approach before
 Drive                 authored turn slows or stops and recovery
                                                                    the defense regroups.
                       lasts longer.

 Coordination          The array folds or shorts; shared-contact    Break individual sightlines and separate
 antenna               callouts cease.                              Slate from the attacking pilot.

                                                                    Choose a safe break and return through a
                       Charge mechanism opens, sweep corridor
 Lance and core                                                     route that remains reachable without full
                       appears, then cooling exposes the core.
                                                                    boost.



Terminus failure and the drive overstrain
Place one checkpoint after the initial defended approach and another before the final hull failure once the core
outcome is settled. Save removed systems, remaining launch groups, pilot condition and rival outcome. A late
collision retries the escape from its defined opening condition and cannot repay the boss reward. A lance
warning must account for turning, distance to safety and current speed. A fixed dramatic countdown cannot
justify an impossible escape.




                                                                                                   Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 7>

FOXLIKE PHASE 05


The proposed failure sequence is core shutdown, weapon power loss, venting, a declared bay-section
separation, then a slow hull roll that clears the convoy route. Confirmed core defeat stops new weapon fire
immediately; already launched projectiles retain their ordinary rules. Mark the separating solid section and its
swept path before it moves. Keep smaller debris cosmetic. The escape checkpoint starts before that sequence,
with a repeatable hull pose and two measured clearance routes. This capital sequence supplies Phase 6 with
an accepted starting contract for larger emergency wreck states.
Dragonfly's overstrain is an authored cost of pulling the convoy from the collapsing drydock. Store it separately
from preventable hull and component damage. Show the extraction effort before the failure, then report the
need for a replacement drive component. Do not deduct defense credit, damage the player by script or
secretly worsen the carrier's hull record to force this transition. Bastion unlocks from settled Terminus success.
The blockade victory stands; Crown's remaining relay control supplies the next strategic problem. Phase 6
owns the final conditional status text. [S19]

P5 2 Jackal route and the three yards
P5.2 Sol Medium. Author a roughly 900 by 260 route envelope containing three compact yards and connecting
approaches. The envelope describes the whole industrial route, not the tank's lateral steering range. Preserve
Jackal's existing steer, aim, fire, brake and hover inputs. Prototype branching forward corridors selected by
visible lateral positioning before a fork. Each branch has an authored centerline and joins the same next
objective without snapping the tank between positions. [S05]
Yard entry gates may hold forward route progression while the player fights locally, then resume after the exit
opens. This is new mission behavior requiring a clear cue and camera test. It must not silently turn the brake
into reverse driving. For the initial prototype, grounded moving recharge remains sufficient on every required
path. A marked refuge that stops while brake is held is a separate director choice to test before it becomes
necessary for survival.
The outputs are a route blockout, branch and checkpoint map, terrain collision, visible landing areas and
ground-to-air support assignments. Companion aircraft use a clear overhead volume and actual firing arcs.
They can pressure a walker or protect a recharge stretch without hitting through roofs. Starter companions
must complete every yard. Bastion makes an exposed pause easier; Pike shortens armor exposure; Glint clears
light pursuers.
Acceptance named Two useful routes requires a playable ground route and a shorter fuel-spending approach
with different exposure. Neither may be a decorative path. Acceptance named Recoverable shortfall requires
an exhausted-fuel test that reaches a catch deck, a safe ground alternative or the nearby checkpoint without
trapping Jackal. Required repair parts become secured only when Iron Maw is defeated and the route is open.
Optional cargo affects later support, never access to Anchorage.

 Yard                   Player problem                               Purposeful variation

                        A short broken crossing and low cover        The ground branch takes longer but offers
 Service approach       teach takeoff, fuel reading and a safe       continuous recharge; the jump exposes the
                        descent.                                     tank briefly.

                                                                     Force its aim away, disable its gun or use
                        A walker covers the direct crossing and
 Gantry yard                                                         the covered branch while companions
                        turns slowly between approaches.
                                                                     pressure aircraft.



                                                                                                    Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 7>

FOXLIKE PHASE 05



 Yard                  Player problem                                Purposeful variation

                                                                     Damage running gear to fix its next firing
                       Iron Maw changes mortar position while
 Supply yard                                                         position, then exploit the route that its
                       the repair convoy waits behind shelter.
                                                                     remaining gun cannot cover.



Hover tuning must use the ground controller
The inspected fuel reserve is 100, draining at 26 per second during hover and recharging at 35 per second
while grounded. That gives about 3.85 seconds of fuel and 2.86 seconds to refill from empty. Ascent
approaches 10 units per second with acceleration 30; gravity is 24, downward speed is capped at 15, and the
current height limits are minus two to eight. These source values describe the existing local controller, not a
tested terrain traversal envelope. [S17]
Try 32-to-40-unit teaching gaps and optional 50-to-60-unit gaps only as blockout candidates. At 18-unit brake
speed, even a 40-unit crossing takes 2.22 seconds before lift and landing are counted. Measure the whole path
at cruise and brake, with full, half and exhausted fuel. Require roughly a quarter-tank reserve on the intended
teaching route after an ordinary takeoff. If the geometry fails, shorten the gap or add a landing shelf. Do not
solve it by silently increasing fuel during that crossing. A held hover input after exhaustion must also respect
the existing release-to-rearm behavior.

P5 3 Walker adaptation and readable commitment
P5.3 Sol Medium. Pin the PR13 walker rig and preserve its origin. The donor preview has hip, knee, ankle and
foot nodes, a 1.35-second gait cycle and a stable two-foot return. Its animation does not move the parent
transform. Checked donor poses span 4.58 by 5.03 by 3.81 units; measure any Foxlike scale change before
deriving corridors or hit geometry. Package 13 movement costs, turret rules and ground missions remain
separate PBR work. [S11] [S12]
Create a bounded Foxlike behavior sequence of travel, turn, plant, aim, fire and recover. Ground navigation
requests a valid root path. The gait follows traveled distance, with feet staying planted during stance. Turning
either uses small planted steps or a declared pivot sequence; rotating the whole model over fixed feet is not an
acceptable finished turn. Start with slow travel and a 1.2-second brace, then a visible aim commitment and
approximately two seconds of recovery. These timings are provisional.
The walker may track within its declared torso arc while braced, but it cannot instantly swivel through a
blocked direction. A tank crossing behind that arc forces a turn and another brace. Gun damage stops its shot
contribution. Knee damage triggers a defined supported kneel or collapse, disables travel and updates collision
to the same final pose. Avoid a random physics fall that blocks the only legal route.
Outputs are the donor manifest, root-motion adapter, behavior profile, attack cues and explicit gun and leg
failure states. Dependencies are P5.2 terrain and P5.4's confirmed firing events. Acceptance named Read the
stance requires a human to identify the committed shot before its muzzle flash. Acceptance named Planted
feet compares moving, stopping and turning captures against root distance, including interruption during a
swing.




                                                                                                    Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 7>

FOXLIKE PHASE 05



P5 4 Ground motion damage and paired previews
P5.4 Sol Medium. Complete Jackal track travel, jet ignition, hover, descent, landing compression and firing
recoil. Track motion follows ground distance and stops during a stationary hold. Hover does not animate the
tracks as though they still grip the floor. Landing compression follows the resolved touchdown speed and
settles within the vehicle's clearance envelope. Use a confirmed weapon-fire event for recoil; incoming-hit
flash must not masquerade as a cannon shot. [S05] [S21]
Iron Maw keeps its mortar identity. Damage to one running assembly prevents its planned relocation or
changes the next firing position; it does not create an unexplained extra boss health bar. Preserve separately
disabled guns and give each a readable mechanical failure. An immobilized but armed Maw still fires through
its valid arcs. The player earns a safer crossing by choosing which capability to remove, while the final core
opportunity remains available to every companion pair.
Outputs are ground motion and damage families with reset, interrupt and settled poses, plus paired previews
in Foxlike and the existing PBR review scenes. Foxlike proves physical traversal and correct weapon
contribution. PBR proves that presenting the same gait, recoil or failure does not alter tactical root, cell, facing,
AP, hit result or gameplay RNG. This evidence supports later PBR package 13 work; it does not complete that
package. Acceptance named Motion matches travel includes a stopped tank, a braking landing, a walker
turning near cover and an immobilized Maw firing its surviving gun. [S10] [S11] [S12]

P5 5 Agreed part names and material states
P5.5 Sol Light. After P5.1, P5.3 and P5.4 settle their rigs, assign the agreed stable names to bay doors, drive
nozzles, antenna, lance aperture, tracks, turret, walker joints and muzzles. Wire existing intact, damaged and
disabled material states to confirmed component state. Populate the manifest's dimensions, axes, source
hashes and socket descriptions. Naming work cannot resolve an undecided pivot or invent a damage rule.
Acceptance named Complete mapping requires every gameplay-referenced part to resolve to the intended
visible part after reset and load. Missing sockets produce an explicit review failure. Once a rig change or new
state is required, return that work to the responsible Sol Medium package rather than hiding it inside this
bookkeeping task.

Portable assets and limits of reuse
The shared vehicle asset owns geometry, pivots, sockets, local poses and explicit part-state inputs. Foxlike
owns world movement, collision, damage, ammunition and objective outcomes. PBR retains tactical rules.
Cameras separately control shake, framing and emphasis. Model scale, world travel and tactical presentation
offsets remain distinct. A reduced-motion camera must not change landing damage, lance timing or a core
opportunity. [S19]
Export capital bay and drive failures toward PBR package 5; export tank and walker motions toward package
13; treat air support presentation as useful to package 15. Capital wrecks belong with package 5. Package 12
concerns city, bridge and utility ruin states, so only a specifically adapted city ruin variant belongs there.
Include source commit, dimensions, negative-Z forward, positive-Y up, pivot limits, pose inputs and reset
behavior. The transfer begins with pinned procedural assets and review scenes; no universal combat
framework or new mesh pipeline is required. [S08] [S10] [S12]




                                                                                                      Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 7>

FOXLIKE PHASE 05



Experiments risks and completion evidence
First compare bay-first and drive-first Terminus runs with the same finite force budget. If the player cannot
explain the difference, change the consequences before adding enemies. Then record a low-energy lance
escape and an escape with one companion withdrawn. Inspect the available route, contact history and
collision trace when either looks unfair.
For Cinder, test both branches at cruise and brake with full, half and empty fuel. A missed jump, simultaneous
gun and knee damage, a companion withdrawing during a crossing and a checkpoint loaded after Maw's
mobility failure are the important state risks. A newly collapsed walker cannot close both routes. An unopened
reserve cannot spawn twice after load. A dead component cannot keep firing because its animation has not
finished.
Completion evidence includes an uninterrupted Standard run of each mission, an intentional failure and
checkpoint retry, starter and specialist companion pairs, and paired PBR presentation checks. Keep arranged
animation captures separate from human gameplay. Automated checks should cover fuel and movement
bounds, component transition ownership, finite reserves and settlement, because those can silently invalidate
the design. The October source audit and prior assertion counts do not satisfy these new gates.
The Phase 6 handoff contains settled drive overstrain separately from preventable damage, parts secured,
optional cargo outcome, companion withdrawal and rival records, and accepted capital motion states. Update
the existing import and progress documentation when implementation occurs. Do not create another
campaign feature list.

Director choices and authorship note
Jonathan should review the corridor-based Jackal blockout before production art. The consequential choice is
whether marked refuge pads may stop the tank while brake is held, or all recharge remains on moving ground
paths. Compare both with existing controls. Also confirm Sovereign's first-system core rule after the two
approach tests. These choices refine the authorized missions without adding an equipment economy or
mandatory specialist.
This phase companion is version 1.0, dated October 23, 2026, directed by Jonathan Sanders and drafted with
Channel Hideo. It inherits H1 to H8 and A3 to A8 from parent revision 2.0. H9 records the human request for
separate expanded phase documents. All new geometry, timings, component rules and acceptance proposals
remain AI-origin elaboration of A4 to A8. No gameplay implementation or new human playtest is claimed.
[S19]

Sources and related handoffs
S01 Foxlike source baseline inspected on October 23 2026
S05 Foxlike controller tank movement boss damage and campaign flow
S08 Foxlike carrier and asset import provenance
S10 PBR Foxlike flight lab on the inspected open draft PR12
S11 PBR walker rig and gait preview on the inspected open draft PR13
S12 Existing PBR campaign packages including capital city and ground work
S17 Jackal hover fuel ascent gravity and grounded recharge
S19 Parent Foxlike campaign plan revision 2 dated October 23 2026
S21 Foxlike procedural tank capital and boss rigs and existing animation




                                                                                                   Planning 1.0 | 7
