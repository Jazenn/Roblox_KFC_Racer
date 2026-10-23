# Repeatable Studio smoke scenarios

Run in a local Play session of the prototype, not a live published server.
These exercise actual engine behavior; portable rule tests do not replace them.
The MCP execute tool must target the stated Client/Server datamodel.

## Startup regression (Server)

Expected: healthy avatar remains seated and the idle van settles. This assertion
failed before the mechanical/seating fixes and passed afterward.

```lua
task.wait(2)
local van = workspace.ChassisPrototypeWorld.PlayerVan
local humanoid = game:GetService("Players"):GetPlayers()[1].Character:FindFirstChildOfClass("Humanoid")
assert(humanoid.RootPart and humanoid.Health > 0, "Driver rig lost")
assert(van.DriverSeat.Occupant == humanoid, "Driver not seated")
assert(van.PrimaryPart.AssemblyLinearVelocity.Magnitude < 3, "Idle instability")
```

## Reset transition (Client, then Server)

Disable ordinary control packets only for the scripted test; restore the script
afterward. Expected: a new van near the start with a healthy seated driver.

```lua
local player = game:GetService("Players").LocalPlayer
player.PlayerScripts.ChassisPrototypeClient.Enabled = false
task.wait(0.2)
game.ReplicatedStorage.ChassisPrototype.Controls:FireServer("reset", 0, 0, false)
```

Then on Server:

```lua
task.wait(0.5)
local van = workspace.ChassisPrototypeWorld.PlayerVan
local humanoid = game:GetService("Players"):GetPlayers()[1].Character:FindFirstChildOfClass("Humanoid")
assert(humanoid.RootPart and humanoid.Health > 0, "Driver lost after reset")
assert(van.DriverSeat.Occupant == humanoid, "Reset did not reseat driver")
assert((van.PrimaryPart.Position - Vector3.new(0, 5.2, 50)).Magnitude < 5, "Reset position")
```

## Invalid controls (Client, then Server)

```lua
local remote = game.ReplicatedStorage.ChassisPrototype.Controls
task.wait(0.2)
remote:FireServer("drive", 0 / 0, 0, false)
remote:FireServer("drive", 1, {}, false)
remote:FireServer("drive", 2, 0, false)
remote:FireServer("teleport", 0, 0, false)
```

Then on Server, after 0.4 seconds, repeat the startup assertions without the
initial two-second delay. Expected: rejected inputs do not move the van or
remove its occupant. This scenario passed against the integrated server.

## Physical wall impact

Temporarily disable SlalomMarker collisions on Server to isolate the wall.
Reset and wait for seating, then on Client send throttle at ten packets/second
until the van reaches ImpactWall. On Server, monitor PlayerVan's State and
instance identity. Expected: a WRECK state, no replacement for at least three
seconds, then a new van and healthy seated avatar. Observe ragdoll/camera
behavior separately rather than treating a state string as proof of visuals.

The first run without isolating markers hit a marker and demonstrated only
wheel-loss damage. The isolated wall run passed the timed recovery assertions.
Restore marker collisions and re-enable ChassisPrototypeClient afterward, or
restart Play to discard all runtime fixture changes.

## Keyboard response regression

In a fresh Play Client, execute `tests/input-response.client.lua` through MCP.
Then use the keyboard tool to hold W+D for 300 ms, release both, hold S for
250 ms, and release S. After 2.5 seconds read
`workspace.ChassisResponseProbe:GetAttribute("Result")`. The probe asserts that
motor, steering, and brake targets react within 100 ms. This measures actuator
command latency, not display latency or the time to reach full steering lock.

Observed against this revision: throttle approximately 0.82 ms, steering
0.42 ms and brake 0.58 ms, all in the input frame. The earlier control path
received the same simulated W/D key events but left the VehicleSeat axes and
actuator targets at zero throughout the three-second observation.

## Speed retention and rollover

Use a clear flat-pad run to isolate handling from scenery. Temporarily disable
collisions on test fixtures other than Asphalt in the running session only.
From reset, hold W for two seconds, then keep W down and hold D for 900 ms.
Release both. Sample road speed, chassis UpVector.Y, wreck state and recovery.

Expected: the turn initially retains speed; sustained hard steering at speed
can tip the van and produce a physical wreck. With the final load-transfer
revision, speed was 77.9 studs/second immediately before steering and 81.9
studs/second after 150 ms. Minimum UpVector.Y was -0.335 and a wreck was observed.
The owner must judge how readily this should happen; it is not a locked tuning
decision. Restart Play afterward to restore all fixture collisions and remove
runtime probes.

## Airborne assistance boundary

In the local Play Client, an internal test applied an upward/forward impulse
to the van, then held D. At 56.8 horizontal studs/second and height 14.7 studs,
the TurnLoadTransfer torque was zero. Expected: no extra roll assistance when
the wheels have no supporting contacts. This does not replace real jump tests.
