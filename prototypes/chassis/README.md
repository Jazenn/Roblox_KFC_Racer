# Throwaway chassis experiment

Decision: [Choose the chassis through a driving and crash prototype](https://github.com/Jazenn/Roblox_KFC_Racer/issues/2).

This is a disposable physical-wheel experiment, not the first playable game or its finished track. It tests prismatic suspension, springs, steering servos and driven wheel hinges. No raycast chassis has been ruled out; the owner must drive this one before we choose.

## Run

Build with Rojo 7.7.1:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
rojo build prototypes/chassis/default.project.json --output build/chassis-prototype.rbxlx
```

If the Rokit launcher reports `home directory not found`, the installed binary currently works directly:

```powershell
& "$env:USERPROFILE/.rokit/tool-storage/rojo-rbx/rojo/7.7.1/rojo.exe" build prototypes/chassis/default.project.json --output build/chassis-prototype.rbxlx
```

Open that place in Studio and press Play. The server creates an internal test pad and seats the first player. Drive with WASD/arrows, hold Space for the rear handbrake, and use R to recover while driving. Severe wrecks must play for three seconds before automatic recovery; there is no skip. Recovery returns to the prototype start, not race checkpoints. Stop Play to discard the test pad.

## Evaluate together

The steering revision reads keyboard press/release events directly and predicts
the physical wheel commands locally. The server assigns the seated driver
physics ownership, validates control packets and retains crash/recovery decisions.
Inside and outside wheels use different steering angles and rolling speeds to
reduce tire scrub. Gas and brake commands bypass the old periodic input wait.

A grounded arcade load-transfer torque makes sustained hard steering above
65 studs/second lean and tip the van; gentle steering and low speeds add no
extra roll torque. Full-speed hard steering builds assistance over 1.4 seconds,
with an initial grace period and a gradual ramp; lower speeds build it more
slowly. Releasing steering drains the buildup, and changing direction starts
fresh. At least two wheel-contact raycasts must detect supporting
ground, and the assistance cuts out when the body tips or becomes airborne.
This supplements the mechanical chassis rather than simulating cargo inertia.
It does not teleport the van into a flipped pose. The body mass is unchanged.

Client-owned physics is responsive but untrusted. Server validation of control
packets alone does not establish competitive multiplayer or prevent a modified
client from manipulating its owned physics. Those remain later design/testing
requirements; this prototype has no saved or competitive results.

1. Drive slowly, then at speed through the markers. Is steering responsive without feeling weightless?
2. Cross and ride the red/white kerbs. Small kerbs should not routinely launch or immobilize the van.
3. Approach the jump in the left lane toward the far wall. Compare straight and crooked takeoffs, landings, and suspension rebound.
4. Glance along the far wall, then strike it directly at speed. Compare small scrapes, detached-wheel driving, and severe wrecks.
5. Hit the empty van at the far right. It should move under impact rather than behave like an anchored prop.
6. Roll or flip the van. Actual severe impacts detach parts and eject the driver.
   Remaining overturned triggers recovery without forced part detachment.
   Both paths retain the mandatory three-second viewing period.

Acceleration uses 8000 drive torque (formerly 12000), keeping the same top
speed and braking. Moderate damage sheds one door per van, preserving all
four wheels; severe wrecks can still shed a wheel and body panels.
Damage uses horizontal speed loss over a 0.3-second window, gated by recent
chassis/body contact. Ordinary wheel contact and speed loss without a body hit
do not trigger breakage. Part damage requires at least 45 studs/s before the
hit and 35 studs/s lost; full wrecks require at least 70 before and 60 lost.
Explosion effects remain outside this chassis test.

Fixtures, tuning numbers, blocky bodywork and HUD are temporary. The tire-wall fixture is an anchored collision proxy; it does not yet prove impact cushioning. This prototype has no race, song, explosion effects, finished art, saved data, or multiplayer verification. The empty target resets every 40 seconds.

## Checks

Pure rule checks:

```powershell
lune run prototypes/chassis/tests/drive.test.lua
luau --coverage prototypes/chassis/tests/drive.test.lua
node scripts/chassis-coverage.mjs
node scripts/floor-guard.mjs --base HEAD
```

Security uses Semgrep's experimental Lua parser. Source deliberately stays within the untyped Lua syntax subset accepted by Roblox; typed Luau support is not assumed:

```text
semgrep scan --config security/chassis.yml --strict --metrics off --json security/chassis.lua > build/security-fixture.json
node scripts/chassis-security-fixtures.mjs
semgrep scan --config security/chassis.yml --error --strict --metrics off prototypes/chassis/src
```

The custom rules check dynamic code execution, numeric remote module loading and runtime asset/network loading. They are not a proof of security. Driver identity, finite bounded inputs, command allowlisting, rate limits and stale-input timeout are enforced server-side; pure-rule tests cover malformed/non-driver input cases. Studio integration must verify the real boundary.

No runtime package dependencies are introduced. Rojo, Luau and Semgrep are development tools. CI records logic coverage, compiles all scripts, checks the security rules and scans source. Engine physics, avatar compatibility, camera behavior, project-wide runtime coverage and feel still require Studio evidence. A place-file build is not proof those behaviors work.

## Evidence and capture

Current local check results and Studio observations belong in `EVIDENCE.md`. Pending checks remain unverified. Keep the decision issue open until live owner feedback supports a choice and a durable throwaway-branch artifact is captured. The repository had no commits at the start; do not commit the owner's existing untracked policy files merely to manufacture a branch base.
