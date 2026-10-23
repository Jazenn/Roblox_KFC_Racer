# Chassis experiment evidence

This is a work log, not a verdict or a completed acceptance report.

## Local checks

- Direct Lune 0.11.0: `lune run prototypes/chassis/tests/drive.test.lua` passed 37 assertions, including bounded finite controls, driver authorization, rate limiting, braking versus reversing, rear handbrake behavior, damage classification and the three-second recovery boundary.
- Direct Rojo 7.7.1: `rojo build prototypes/chassis/default.project.json --output build/chassis-prototype.rbxlx` produced a place file.
- Official Luau CLI 0.743: `.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua` passed the same 37 assertions and produced LCOV data.
- `node scripts/chassis-coverage.mjs` measured DriveModel.lua at 39/39 instrumented lines (100%). All those lines are new; engine project/changed-line coverage remains unmeasured.
- `.tools/luau-0.743/luau-compile.exe --null <source>` compiled all four files in `prototypes/chassis/src/` successfully.
- `node scripts/floor-guard.mjs --base HEAD` passed after source, test, security-rule and CI additions.
- Semgrep 1.182.0 via `uv tool run --from semgrep==1.182.0 semgrep scan --config security/chassis.yml --error --strict --metrics off prototypes/chassis/src`: three Lua rules scanned all four files, approximately 100% parsed lines, zero findings. These are limited-scope source checks, not a security proof.
- Semgrep's built-in fixture runner did not recognize Lua comment annotations. Actual JSON-result validation preserves all fixtures: `semgrep scan --config security/chassis.yml --strict --metrics off --json security/chassis.lua` followed by `node scripts/chassis-security-fixtures.mjs` passed all seven expected rule/line pairs with the safe require unflagged. The validator handles the Windows PowerShell UTF-8 BOM.

## Pending evidence

- Existing secrets scans: local Gitleaks is unavailable; CI has not executed.
- CI execution; no commits/branch have been published.
- Remaining Studio scenarios: human handling feedback, deliberate steering/kerb/jump comparisons, empty-van impacts, damaged driving, and repeated crash/recovery stress. The observed live scenarios below are not a substitute for these.
- Owner driving feedback and chassis verdict.
- Project-wide and engine changed-line coverage remain unmeasured; pure-rule coverage alone cannot establish those baselines.

## Installation state

The owner authorized installation in the connected place. The current connection
identifies it as Roblox_KFC_Racer, placeId 128617506057924 (DataModel name Place2).
Its Workspace was inspected and contained only Camera, Baseplate, Terrain and
SpawnLocation. Prototype scripts were added to dedicated ChassisPrototype
containers and StarterPlayerScripts. The original scene was preserved. This is
an open Studio edit, not a claim of saving/publishing the place or capturing a
versioned prototype branch.

## Studio observations (2026-10-21)

- Initial file transfer serialized PowerShell metadata instead of source text;
  scripts contained `{}` and failed parsing. Corrected by transferring plain
  source strings and inspecting installed Source. Disk source was not affected.
- Reproduced a transient client error when PlayerVan replicated before
  DriverSeat. Added an explicit seat-availability guard; subsequent HUD and
  camera startup were observed working.
- Reproduced catastrophic joint instability with the original tiny suspension
  carriers/hubs: the van and seated avatar could be flung out of the world.
  Isolated startup from local controls; the failure was not reliably limited to
  client input. Increased carrier/hub mass and reduced steering servo torque.
  Added seated-driver collision filtering and explicit server ownership.
  After these revisions, healthy seated startup and idle stability assertions
  passed in Studio. No individual change is claimed as the sole cause.
- Forward drive: sent twenty validated throttle packets at 0.1-second intervals
  through the actual client RemoteEvent. Observed 108.7 studs forward travel and
  approximately 78.2 studs/second, with a healthy seated driver.
- Manual reset initially left the driver unseated. Explicitly release the old
  seat weld and allow the seating transition to settle. A live regression
  assertion then confirmed reset restores a healthy seated driver near start.
- Invalid-input integration: sent NaN throttle, table steering, out-of-range
  throttle and an unsupported command through the real client boundary.
  Subsequent assertions confirmed no motion or loss of seating.
- An initial straight-drive scenario struck a slalom marker and entered the
  detached-wheel damage state. This did not establish wall-crash behavior.
- Isolated wall scenario: temporarily disabled slalom marker collisions only
  in the running test instance, reset, and sent throttle toward the far wall.
  Observed the severe-wreck state followed by van replacement and healthy
  reseating. The monitor confirmed at least three seconds elapsed before
  recovery; its final 3.416-second observation includes a 0.4-second post-reset
  seating check. Marker collisions and normal controls were restored afterward.
- Screen capture confirmed the HUD, blocky van, kerb/marker lane and jump are
  visible. This is not owner approval of handling, finished visuals, or camera
  quality. Roblox avatar-asset/Core UI warnings were also present in Studio;
  they are not counted as prototype verification failures or silently reported
  as a clean console.

After these integration fixes, all 37 assertions, 39/39 portable-rule coverage,
compilation of all four scripts, the Rojo place build, the floor guard, and the
Semgrep scan (three rules, four parsed files, zero findings) were rerun and passed.
The decision remains open. Owner feedback and durable branch capture are pending.

## Prototype architecture

The current revision assigns the seated driver physics ownership and predicts
wheel commands locally. The server validates bounded throttle/steering/brake,
driver identity, rate and command allowlists, and decides damage and recovery.
Control packets do not carry transforms or crash assertions. Client-owned
physics itself is untrusted: packet validation is not proof against a modified
client manipulating the vehicle. Competitive multiplayer remains unverified.
Ownership is revoked on wreck or an empty seat. A grounded arcade load-transfer
torque supplements physical contacts/joints; it is neither an upright lock nor
an airborne steering force.

## Steering and input revision (2026-10-21)

Owner feedback accepted the crash feel and weight but rejected sluggish input,
large steering radius, speed loss in turns, and the lack of hard-turn rollovers.
This revision keeps the body's mass and crash/recovery timing.

Regression evidence before implementation:

- `luau prototypes/chassis/tests/steering.test.lua` failed at the tight-turn
  full-lock assertion against the previous model. The old model reduced lock
  from 29 degrees to about 12 degrees at top speed.
- In the virtual-keyboard path, W/D InputBegan events were delivered but default
  VehicleSeat axes and motor/steering targets stayed zero during the three-second
  probe. This reproduces a weakness in the indirect input path; it does not claim
  physical keyboard input always did nothing.
- A direct-command baseline showed two front servos at approximately -3.8 and
  -43.5 degrees for a shared -12.3-degree target. That sample supports steering
  mismatch but did not reproduce all of the owner's reported speed loss.
- Before load transfer was added, a hard-turn probe retained speed but barely
  leaned (minimum UpVector.Y 0.991); this failed the requested rollover behavior.

Changes: immediate key-state input, local wheel prediction with driver ownership,
20 Hz periodic validation refresh plus immediate edge sends, faster wheel motors
and steering servos with mechanical limits, inner/outer steering geometry and
rolling-speed differentiation, and more tire grip. Reset validation has a separate
clock so drive refresh packets do not consume its rate budget. Stale inputs and
focus loss neutralize controls. Sustained hard steering above 55 studs/second
adds ground-contact-gated roll torque; normal steering adds none.

Observed after implementation:

- `tests/input-response.client.lua`, followed by real MCP keyboard W+D for
  300 ms then S for 250 ms, passed its 100 ms command-response limit. Measured
  throttle 0.82 ms, steering 0.42 ms, brake 0.58 ms. These are actuator target
  changes within the input frame, not end-to-end visual/vehicle-settling latency.
- On a clear-pad W-for-two-seconds then W+D-for-900-ms run, speed was 77.9
  studs/second immediately before steering and 81.9 after 150 ms. UpVector.Y
  reached -0.335 and the van entered WRECK. A later check confirmed a healthy
  reseated driver and restored ownership after automatic recovery.
- A physical upward/forward impulse created an airborne hard-steering test at
  56.8 horizontal studs/second, height 14.7. TurnLoadTransfer torque was zero.
- Direct-key R reset passed. After all tests, Play was restarted to restore
  fixture collisions and remove runtime probes. Fresh-session seated idle
  assertions passed; the prototype is left running with normal controls.

Final local commands/results:

- `.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua`:
  37 retained baseline assertions plus 14 steering/input and 8 rollover assertions
  pass. `node scripts/chassis-coverage.mjs`: 57/57 instrumented rule lines (100%).
- `.tools/luau-0.743/luau-compile.exe --null <source>`: all five runtime scripts
  and all three Lua test/probe files compile. CI now compiles both globs.
- Rojo 7.7.1 build of default.project.json succeeds.
- `node scripts/floor-guard.mjs --base HEAD`: clean.
- `uv tool run --from semgrep==1.182.0 semgrep scan --config security/chassis.yml --error --strict --metrics off prototypes/chassis/src`:
  three rules, five files, approximately 100% parsed, zero findings.

Owner feedback on the new handling remains required; the wayfinder decision
stays open. Engine/project-wide coverage, CI/secrets results, sustained stress,
and durable throwaway-branch capture retain their previously stated limits.

## Small rollover softening after owner re-test

The owner accepted the revised handling but found tipping too eager and asked
for a simple adjustment with light verification. Extra roll assistance now
starts above 65 instead of 55 studs/second, still reaching full strength at 78.
Peak torque scaling drops from 5.5 to 4.6 (about 16%). Steering, input response,
body mass and crash/recovery rules are unchanged.

Two additional boundary assertions failed before the change, then passed.
The quick rule suite now passes 61 behavior assertions; portable coverage
remains 57/57 lines (100%). Changed actuator syntax compilation and the floor
guard pass. The two modules were updated in Studio and Play restarted.
Earlier measured rollover trajectories describe the previous stronger tune;
no full handling/stress re-test is claimed for this small adjustment.

## Sustained-turn rollover buildup

Further owner feedback requested time to turn before tipping at full speed.
Extra roll torque now ramps with continuous hard-turn exposure: 1.4 seconds
to full assistance at maximum speed, with a quarter of that buildup providing
no added torque. Lower speeds accumulate exposure more slowly. Releasing the
turn or losing ground contact drains exposure and removes assistance;
reversing steering starts fresh. Elapsed time is capped to prevent a stalled
frame from instantly applying full assistance. Steering and input response
remain unchanged.

Ten new temporal assertions failed before implementation and pass afterward.
The suite now passes 71 assertions; portable rule coverage is 69/69 lines
(100%). Both changed runtime modules compile and the floor guard is clean.
Both modules were synced to Studio and Play restarted. No new physical
rollover trajectory or full handling/stress re-test is claimed; owner feel
feedback and the existing engine-coverage limitations remain pending.

## Collision window and separate overturned recovery

Owner feedback: wall/pole impacts often caused no breakage, while flipping
caused parts to detach after a delay. The former used only consecutive-frame
speed loss; the latter explicitly called destructive wreck logic after 1.4
seconds upside down.

Damage now compares horizontal speed against the preceding 0.3-second peak,
requiring chassis or still-attached body-panel contact within 0.15 seconds.
Wheel-only contacts, self-contact, the driver and noncollidable parts do not
qualify. Moderate impacts retain one-wheel damage; severe impacts still break
panels and eject the driver. Overturned/off-pad recovery uses a separate path
that locks controls and waits three seconds without forced damage or ejection.
No steering, torque, mass, rollover tune or explosion effects changed.

`tests/impact.test.lua` failed before implementation on the missing window
function. Its 11 assertions now pass, including a 78→60→42→20 collision over
150 ms, expired peaks, loss without body contact, slow tumbles, already-damaged
vans and separate recovery reasons. All 82 suite assertions pass.

Commands/results:

- `.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua`
  and `node scripts/chassis-coverage.mjs`: 86/86 portable lines (100%).
- `.tools/luau-0.743/luau-compile.exe --null <file>`: all changed runtime files
  and the new impact test compile.
- Direct Rojo 7.7.1 `build prototypes/chassis/default.project.json --output build/chassis-prototype.rbxlx`: succeeds.
- `node scripts/floor-guard.mjs --base HEAD`: clean.
- Existing Semgrep source command: three rules, five runtime files,
  approximately 100% parsed, zero findings.

Focused Studio observations (local Play, controls paused for isolation):

- Physical wall run: assign server ownership, position van at (0,5.2,-290),
  velocity (0,0,-78), normal gravity and wall collisions. Speed dropped from
  about 66 to 12 studs/s near 0.40 seconds; WRECK was sampled at 0.45 seconds
  with one detached wheel. The three-second wreck viewing path remained active.
- Isolated overturn: unanchored van at height 3000, upside down, initially zero
  velocity/angular velocity, no contact surfaces nearby. At two seconds state
  was OVERTURNED RECOVERY, with zero detached wheels. A repeated run asserted
  unchanged body weld count, all wheels attached and RecoveryLocked true.
  This isolates the timer from real landing impacts, which may still damage it.
- An initial anchored version of the overturn probe was inconclusive; use the
  unanchored scenario above because ownership changes require movable parts.

These are narrow engine checks, not full project coverage, multiplayer,
pole/glancing-hit coverage or a stress run. Existing CI/secrets and durable
branch-capture limits remain. Owner handling/damage feedback is still needed.

## Gentler acceleration and survivable collisions

Owner requested slower acceleration and fewer resets from small collisions.
Drive torque is now 8000 instead of 12000; target speed, braking, steering and
rollover tuning are unchanged. Moderate damage requires speed >=45 and loss
>=35, and sheds one door rather than disabling a wheel. Only one moderate
part loss is allowed per van. Full wrecks require speed >=70 and loss >=60;
they retain wheel/panel detachment, ragdoll and mandatory viewing.

The changed acceleration expectation failed before the implementation.
Four new impact assertions cover bumps, full-speed scratches, medium-speed
hard hits and retaining speed after impact. The temporal collision test now
asserts survival at 78→20 and escalation only at 78→5, preserving both damage
and severe-wreck coverage. All 87 assertions pass; portable line coverage
remains 86/86 (100%). Same Luau test/coverage commands as above; both changed
runtime modules compile, Rojo builds, floor guard and git diff --check pass.
Existing Semgrep source command reports zero findings across five files.

Studio physical test: server-owned van at (0,5.2,-295), velocity (0,0,-55),
normal gravity and ImpactWall. After 1.5 seconds it was DAMAGED with DoorLeft
detached, all four wheels attached and RecoveryLocked false. Assertions passed.
This verifies survivable moderate damage; acceleration feel and the newly
raised full-wreck threshold still need owner driving feedback. No new full
stress/multiplayer/CI/secrets verification is claimed. Play was restarted to
restore normal fixtures and controls after the isolated check.

## Softer brief steering inputs

Owner requested less aggressive light taps while retaining the accepted flip
physics. The only runtime change is SteeringServo.AngularSpeed: 12 to 3 rad/s.
Wheel steering now sweeps toward the requested angle more gradually; full lock,
input delivery, drive/brake torque, damage and roll-assistance rules are unchanged.
This is a one-parameter tune, so no artificial constant-mirroring test was added.

Existing Luau suite: all 87 assertions pass; same coverage command reports
86/86 portable rule lines (100%). Build.lua compiles and floor guard is clean.
Studio was updated and Play restarted. Runtime assertions confirmed both front
servos use AngularSpeed 3 with original +/-55-degree limits. This verifies the
installed configuration; tap feel and physical rollover trajectories were not
re-measured and await owner driving feedback.
