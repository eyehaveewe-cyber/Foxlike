# Supplied guide: Foxlike_Phase_08_Campaign_Completion.docx

Source: [original DOCX in Library](https://chatgpt.com/api/library/files/libfile_dc8b87683b50819185e71522b9472145/download). Extracted-text snapshot; the source document remains authoritative. Jonathan’s October 30 direction removes human playtest gates from programming.

<PARSED TEXT FOR PAGE: 1 / 8>

FOXLIKE PHASE 08




Foxlike Phase 8
Campaign completion and release candidate
Version 1.0 | 23 October 2026
Director Jonathan Sanders
Phase 8 makes the completed campaign dependable for someone who did not build it. The player should be
able to import or install the delivered project, choose companions, understand the controls, recover from
failure, finish the return to Dragonfly and replay a mission without stale state. This phase joins the earlier
evidence into a release candidate and investigates the remaining risks with actual play, physical controls and
target hardware. It does not invent another campaign or declare the planned experience finished from source
inspection. The work below defines proposed journeys, failure cases, performance measurements and
deliverables. Every test result remains pending until someone records it against a specific build. Distribution
and commercial release remain separate decisions. Windows and browser support must be described only to
the extent that their own exported builds have been exercised.

Baseline and the meaning of completion
The inherited audit inspected Foxlike main at 84e9d31428e15d1a5271eddc18dac7d4fe0d5782 on 23 October
2026. Its documentation reports 197 native assertions and arranged captures for the six-mission expansion.
That record leaves human balance, physical controller use and Windows hardware performance open, and
reports the later local browser runtime check as blocked. These are historical evidence categories, not results
for the proposed ten-mission campaign. [S01] [S02] [S19]
Continue with the existing Godot 4.7.2 project and Compatibility renderer. Earlier phases own the flight,
missions and reusable assets. Phase 8 owns integrated usability, migration and regression risk, real control
operation, target performance, export checks and honest delivery notes. A source file containing a feature
establishes its presence. A rules test establishes the checked condition. A person completing a mission
establishes a different kind of evidence.
Completion means the selected campaign can be played and understood through its ending under the agreed
configurations. It does not mean every possible input sequence has been tested, every minor defect has
disappeared, or every platform is supported. Declare the evidence and remaining limitations precisely.

Entry criteria and responsibilities
Receive one candidate containing all selected missions, stable mission IDs, agreed unlocks, checkpoint versions
and the Phase 7 ending. The first seven phases should supply their bounded acceptance records, source
hashes, asset manifests and known issues. D1's flight and maneuver controls and D3's rival tone must be
settled before testing final prompts and outcomes. An unresolved encounter cannot be concealed inside a
packaging task.
Freeze the candidate's gameplay data during a named test pass so observations refer to a real build. A later fix
creates a new candidate identity. Recheck the affected journey or state boundary and its immediate
dependents, then repeat the final integration gate when material changes justify it. Do not restart every
completed test because a credit line changed.




                                                                                                  Planning 1.0 | 1

<PARSED TEXT FOR PAGE: 2 / 8>

FOXLIKE PHASE 08


Use the existing progress and verification records for evidence, the concise design document for adopted rules,
and the README for starting and running the project. The phase document remains the plan. Keep actual
defect status and measurements in the project's existing records rather than creating another permanent
feature backlog. [S19]

Whole campaign journeys that answer real questions
Begin with one uninterrupted human Standard journey from a new save through the final carrier return,
without debug invulnerability or reduced boss health. Record the build, selected controls, companion changes,
failures and mission times. The inherited 128-to-157-minute successful-play target is a pacing comparison.
Publish observed times and the places where attention or momentum failed instead of forcing the recording to
fit that range.
Use a separate journey to exercise failure and recovery deliberately. Include a failed escort intervention,
exhausted Jackal hover fuel, a companion withdrawal, a damaged carrier recovery and a late Crown escape
crash. The important observation is whether the player understands the cause, knows what retry restores and
can continue. A checkpoint that technically loads but repeats a long completed boss fight fails that experience.
Cover the starter pair across mandatory combat responsibilities, then use alternate pairs to expose each
specialist's contribution. The roster has ten unordered two-pilot combinations when all five are available. That
does not require ten full campaign recordings. Use focused critical-objective checkpoints for pair-dependent
risks, and broaden human trials where a failure suggests an exclusive ability requirement or an unreadable
assignment.
Compare local recordings before changing pacing. Separate time spent orienting, choosing a route, fighting,
waiting and repeating a checkpoint. A long quiet transfer may need a closer objective or clearer heading. It
does not automatically need another enemy wave.

A complete player journey and a plausible failure
A player starts with Latch and Glint, opens Viridia and finds Pike available at the correct stable mission
milestone. Later they switch to Pike and Ember for Terminus. The carrier's authored drive overstrain still
occurs during extraction, while the results recognize that the player protected its hull. Cinder supplies the
replacement parts and Anchorage completes the repair. These transitions should explain the campaign
without requiring the design document.
At Crown, the player disables the launcher and attacks through a timed shield opening. After winning, they
misread a closing wreck route and crash. Retry begins at the defined escape checkpoint with Crown defeated,
the same settled companion condition and no repeated boss reward. Reducing camera shake must preserve
the same route and warnings. The player then reaches Dragonfly and sees the convoy outcomes earned
earlier.
After results, the player replays Aurora with another pair and returns to mission selection. Their campaign
completion, unlocked pilots and final outcome remain intact under the declared record policy. A replay may
improve an allowed score record; it must not replace a completed campaign with an old mid-mission frontier.
This journey connects menu state, save rules, failure recovery and the ending in a way isolated screenshots
cannot.




                                                                                                    Planning 1.0 | 2

<PARSED TEXT FOR PAGE: 3 / 8>

FOXLIKE PHASE 08



Migration replay and checkpoint settlement
Use copies of representative old saves, or generate labeled fixtures with the pinned six-mission build. Include
an early save, each old mission index, completed progression, different difficulty records, a selected loadout
and stored sound preference. Keep a copy of the input before migration. The explicit old-index mapping must
preserve the old mission's identity rather than interpreting its index in the new order. [S06] [S19]
Check that migration preserves earned companions, records and preferences, then assigns documented
defaults for genuinely new fields. Running the migrated save again must not remigrate, duplicate rewards or
change unlocks. Test truncated, unsupported and future-version records through the project's agreed error
path. The player needs a clear recovery choice; silently replacing their progress with a new campaign is
unacceptable.
Exercise settlement at boundaries where state crosses scenes or files: component defeat before checkpoint,
mission success before results, results before replay, companion withdrawal before recovery and Crown
victory before escape. Repeated retry and a process restart must produce the same settled reward and roster.
Simulated interruption tests should target the actual save transaction, not arbitrary animation frames that the
checkpoint contract never promised to preserve.
Enumerate the valid authored rescue and rival combinations for ending selection. Automated checks can
evaluate every reachable selector state, while an author reviews the chosen text and traffic against the
outcome table. Human play should cover representative extremes and any combination with a unique scene.
Do not imply that every combination received a full campaign playthrough.

Risk based verification priorities
Prioritize failures that lose progress, prevent completion, misstate a consequence or violate the shared flight
rules. Reuse earlier checks while their assumptions remain unchanged. Add a new test when a particular
integration risk needs an answer. The following records describe evidence to collect, not completed results.

 Risk                        Focused evidence                                     Closure condition

                                                                                  Mission identity, earned unlocks
 Progress maps to the        Old saves at all six legacy indexes, then a
                                                                                  and historical records remain
 wrong mission               second load of each migrated result.
                                                                                  correct.

 Retry repeats a reward or   Save, retry and reload at defeat and settlement      Exactly one settled result and the
 revives a rival             boundaries.                                          expected roster.

 One companion becomes       Starter pair and targeted alternate-pair trials at   Every available pair has a viable
 compulsory                  each critical responsibility.                        ordinary route to mission success.

 AI or scenery breaks fair   Retained movement checks plus the changed            No unexplained speed, turn,
 flight                      mission's worst crossing and recovery routes.        sensing or collision exception.

                                                                                  Identical route, hazards and
 Presentation changes the    The same checkpoint with full and reduced
                                                                                  gameplay outcome under identical
 escape                      effects and allowed presentation skips.
                                                                                  inputs.




                                                                                                         Planning 1.0 | 3

<PARSED TEXT FOR PAGE: 4 / 8>

FOXLIKE PHASE 08



 Risk                       Focused evidence                                Closure condition

                                                                            Delivered build supports the
 Export behaves unlike      Fresh import, exported launch, save, retry,
                                                                            advertised journey and retains
 the editor                 ending and replay on the declared target.
                                                                            progress.

 Frame stalls hide a        Recorded busiest encounters with frame-time     The agreed performance gate holds
 warning                    and warning timestamps.                         without changing gameplay rules.



Physical controls and binding behavior
Test keyboard and mouse and an actual physical controller. Record the controller model, connection method,
operating system and bindings. Simulated input is useful for rules checks but cannot establish thumb reach,
accidental chords, stick drift or whether an essential button combination is practical. Consume the D1 layout
selected earlier instead of selecting a new maneuver scheme during final testing.
Trace launch, ordinary flight, aiming, boost, brake, roll, each arena maneuver, companion ability, assignment,
formation, target selection, pause, retry and menu return. Test conflicting rebindings, restoring defaults and
switching the active input device. Prompts must follow the actual binding and must not tell a controller player
to press a hard-coded keyboard key.
Concentrate on the known interaction risks. A held assignment control must not fire its tap ability by accident.
Boost combined with a maneuver must have consistent press and release behavior. Pausing while steering,
returning from a menu with a button held, disconnecting a controller and restoring focus must not leave
continuous fire or steering latched. Use the project's chosen safe pause and reconnect behavior.
Adjust sensitivity, deadzone or hold timing only from the affected physical trial. Keep recorded defaults and
expose the settings already agreed for the campaign. A single-action binding alternative for an agreed
maneuver is preferable to making a difficult chord the only route to an essential escape.

Camera readability and essential information
Check the campaign with camera roll, shake and boost FOV movement independently reduced. The craft may
still bank and turn visibly while the camera supplies a stable reference. Preserve aim, damage, timing and the
position of major wrecks under every presentation setting. The parent applies Microsoft's XAG 117 guidance to
these independent motion controls. This phase verifies Foxlike's implementation rather than claiming a
general accessibility certification. [S15] [S19]
Run the high and low threat cases with sound muted and optional chatter cut. Selected-target direction, above
or below information, incoming attack, objective change and escape forecast need a readable visual channel.
Combine shape, placement and short text so color alone never carries the required distinction. A bright storm
flash cannot substitute for the forecast region.
Inspect essential captions and controls at the default UI scale and a provisional 150 percent scale on the
agreed desktop resolution. Verify that text remains inside the display and does not cover the central aiming
decision. Repeat the most crowded controls overlay or storm warning moment, rather than checking only a
quiet menu. If the chosen UI contract uses another supported large-text setting, test that setting instead.




                                                                                                  Planning 1.0 | 4

<PARSED TEXT FOR PAGE: 5 / 8>

FOXLIKE PHASE 08


Ask the player to explain the next objective and the last damage source after a demanding turn. Wrong
answers can reveal a timing or marker problem even when every label exists. Change the affected
communication, then replay that moment. Do not bury the correction beneath more simultaneous radio.

Performance workloads and provisional measurements
The inherited initial target is 60 frames per second at 1080p on Jonathan's agreed Windows PC. Record its CPU,
GPU, memory, operating system, graphics settings and export build. Sixty frames per second corresponds to
roughly 16.7 milliseconds per frame. No current result in this plan establishes that target, and 4K requires its
own measurement. [S19]
Profile representative candidate workloads first: Anchorage with carrier recovery and Harrow, Stormbreak
with cooperating rivals and forecast effects, Crown with all relevant systems active, the falling-yard major
wreck sequence and Cinder's walker crossing. Use the approved actor and projectile budgets. Background
traffic may lower visual detail, but active collision, sensing, targetability and damage cannot change to make a
benchmark pass.
For the busiest cases, propose three 60-second captures after a short warm-up. Report median, 95th-
percentile and 99th-percentile frame times, the worst repeatable stall, active pilot count, projectile count and
major collision pieces. A provisional gate is 95 percent of gameplay frames at or below 16.7 milliseconds, 99
percent at or below 25 milliseconds, and no repeatable unexplained combat stall above 100 milliseconds.
Jonathan should confirm this tolerance against the target hardware.
Trace a failure to its actual cost before changing scope. Effects, projectile management, collision and AI may
require different fixes. Repeat only the affected workload and an ordinary control scene. Loading pauses must
be labeled separately. Check retained memory after repeated retry and replay; a rising baseline after settled
scenes needs explanation before calling the candidate stable.

Editable source Windows and browser exports
Create the candidate's editable source package from a known revision and import a fresh unpacked copy with
the documented Godot version. Check that required models, scripts, audio and mission data exist in the
package and do not depend on an author's absolute path. The README should let another person launch the
project without reconstructing the development environment. This is packaging verification, not authorization
to distribute it publicly.
Test the Windows export outside the editor on the agreed PC. Include first launch, control setup, save
persistence after closing the process, checkpoint retry, the final return and mission replay. Record the export
configuration and tested executable identity. An editor run and a successful export command do not prove this
delivered build works.
Exercise the Web export in an actual browser before claiming browser support. Record browser version,
operating system, hosting conditions and the artifact tested. Check focus loss, pause and resume, input return,
audio initialization, save persistence after reload in the same environment and the largest selected encounter.
No test here implies portable saves between unrelated browsers or origins.
If the browser candidate remains blocked or fails the required experience, describe it as unverified or
unsupported. A verified Windows candidate can have a clearly deferred Web target if Jonathan accepts that
scope. Do not describe the whole release as platform-complete while an advertised target lacks evidence.




                                                                                                   Planning 1.0 | 5

<PARSED TEXT FOR PAGE: 6 / 8>

FOXLIKE PHASE 08



Asset reuse and source packaging evidence
Collect the accepted asset families from earlier phases with their source revisions, dimensions, axes, part IDs,
sockets, pose parameters and reset behavior. Foxlike owns continuous flight, combat and collisions. PBR owns
tactical routes, AP, occupancy and outcomes. The camera owns presentation emphasis. These responsibilities
must remain visible in the delivered notes and examples. [S08] [S10] [S19]
Only rerun paired PBR checks for an asset or adapter changed since its last accepted evidence, or where
integration reveals a new risk. Full, reduced and skipped presentation must preserve the tactical result and
gameplay RNG. A useful pose demonstration cannot establish PBR carrier recovery rules. The dated baseline
still identifies PR12 and PR13 as unmerged implementations; update their status only from new inspected
evidence. [S10] [S19]
Check that credits and provenance accompany reused material, and that source packaging includes the
intended editable assets without accidental unrelated project files. Keep PBR package destinations in its
existing plan. Package 12 remains city, bridge and utility destruction. Finishing Foxlike's ending does not
declare every PBR package complete. [S12]

Evidence records and release candidate decisions
Each meaningful record needs a case name, build revision, platform, input configuration, starting save or
checkpoint, steps, expected behavior, observed behavior, result and evidence location. Mark it human play,
automated rules verification, arranged presentation capture or source inspection. A screenshot proves what
was visible at that instant. A continuous recording can establish a completed sequence and its timing.
Reserve a campaign-blocking status for inability to complete, lost or corrupted progress, an essential
inaccessible control, a reproducible crash or a violation that invalidates a required fairness rule. A wrong rival
outcome or repeated boss reward also blocks its affected journey. Cosmetic defects may remain as explicit
known issues when they do not hide an essential cue or contradict a promised state.
Close a defect with a reproduction of the original failure and the affected neighboring transition. Broaden
checks when the fix changes shared movement, save settlement or scene ownership. Once the concrete risk
and required gates are answered, stop optional verification and prepare the candidate for review.
Keep pending and blocked results visible. A missing human tester, unavailable controller or untested browser
is missing evidence, not a pass inferred from code. The candidate report should allow Jonathan to see which
configurations are ready and which still require work.

P8 1 Campaign journeys and state recovery
P8.1 Sol Medium. Produce the new-save and migrated-save journeys, critical checkpoint and ending fixtures,
focused companion coverage and pacing observations. Dependencies are all selected missions and the Phase 3
state contract. Fix discovered integration defects through bounded follow-up work linked to the failing case.

Acceptance named Complete journey requires an unassisted human Standard finish through playable return.
Preserved progress requires correct legacy mapping, repeat loading, checkpoint settlement and replay
behavior. Coherent outcomes requires every reachable ending selector to agree with its records and
representative unique scenes to be exercised. Deliver recordings, fixture provenance and actual results rather
than a larger assertion total.




                                                                                                     Planning 1.0 | 6

<PARSED TEXT FOR PAGE: 7 / 8>

FOXLIKE PHASE 08



P8 2 Controls camera and comprehension
P8.2 Sol Medium. Produce physical keyboard and mouse and controller evidence, binding and reconnect
checks, reduced-camera trials and a readable essential-information pass. Depend on the settled input contract
and final mission warnings. Include at least one steep duel, hover crossing, companion assignment and final
escape.
Acceptance named Usable controls requires all essential actions on the tested devices without accidental tap
and hold activation. Readable flight requires high and low threats, hazard forecasts and objectives with sound
muted and chatter cut. Stable presentation requires the same gameplay under reduced effects. Record device
details and any unresolved comfort issue; do not generalize from one tester to all players.

P8 3 Performance and exported builds
P8.3 Sol Medium. Produce the measured Windows candidate, fresh source import and actual-browser export
evidence, with a declared status for each target. Depend on the selected build, actor budgets and available
target hardware. Packaging automation or runtime fixes discovered here remain Sol Medium work.
Acceptance named Reproducible delivery requires another unpacked copy to launch with documented steps.
Measured target requires the chosen performance gate and a readable account of stalls and limits. Verified
export requires the supported target to retain saves, recover from failure and reach replay through its
delivered artifact. Browser support remains pending until its runtime journey passes.

P8 4 Credits control text and project records
P8.4 Sol Light. Populate final credits, agreed control descriptions, source packaging notes and concise DESIGN,
README and PROGRESS updates from the measured candidate. Use settled names, actual bindings and
verified platform statements. This task begins after the corresponding behavior has a trustworthy result.
Acceptance named Accurate handoff requires agreement between the delivered build, its starting instructions,
credits, current design and remaining-limit list. New migration logic, platform compatibility work or an input
redesign belongs to the appropriate Sol Medium package. Do not hide those dependencies under a
documentation label.

Final handoff director choices and revision
Deliver one identified release candidate, editable source, tested export artifacts, the evidence index, known
limitations and a short route through the campaign for review. Preserve the historical compact build as the
earlier tagged snapshot without adding a selectable legacy campaign. Mission replay, loadouts, saved records
and the final outcome must remain legible after the full journey.
Jonathan still needs to name the Windows target hardware, confirm the provisional frame-time tolerance and
decide whether Web is an acceptance target or a separately deferred export if its trial fails. Those choices
constrain the release claim; they do not authorize a new renderer, purchases or public distribution. No
commercial price or platform certification commitment is made here.
This version expands parent A8 production planning and A7 reuse acceptance while retaining H1 through H8
through the campaign handoff. H9 records the human request for eight expanded phase documents. Version
1.0, 23 October 2026, is AI-origin planning for director Jonathan Sanders. All proposed trials and completion
gates remain pending. No gameplay implementation, new human playtest, measured performance result or
release approval is claimed. [S19]



                                                                                                  Planning 1.0 | 7

<PARSED TEXT FOR PAGE: 8 / 8>

FOXLIKE PHASE 08



Sources and related handoffs
The source links identify the evidence behind the baseline. The other phase documents describe proposed
work and should be read with the parent campaign handoff.
S01 Foxlike source baseline and README at inspected commit
S02 Dated playtest resolutions and adjacent verification record
S06 Existing companion roster formations and numeric unlock gates
S08 Foxlike asset provenance and import notes
S10 PBR flight lab on the inspected unmerged PR12 branch
S12 Existing PBR campaign packages and their separate responsibilities
S15 Microsoft Xbox Accessibility Guideline 117 camera and visual distractions
S19 Foxlike campaign planning revision 2.0




                                                                                              Planning 1.0 | 8
