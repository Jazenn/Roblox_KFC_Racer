# Preliminary visual and physics performance research

Archived for [Set the visual and physics performance budget](https://github.com/Jazenn/Roblox_KFC_Racer/issues/7), on research/performance-budget. This captures existing preliminary tracker findings, not a new profiling investigation. No numerical performance budget, named owner-approved baseline device, or measured representative crash result is established.

## Capture context and current status

Owner approved durable source/artifact publication. Source snapshot: 507bb4c6aabee918b07b7f551a8e54cbff58fa89; this branch also includes the subsequent floor-guard repair. Chassis, visual and circuit design decisions have since closed. The old comment's references to those blockers and the unborn repository are retained below as historical evidence; they no longer describe current artifact availability.

The original visual sample is static and the approved recovery/explosion system is not production-integrated. A baseline desktop/resolution/graphics setting must be agreed and an appropriate representative driving/crash/recovery scene measured before final budget approval. Measurements must cover frame times, physics/script cost, memory, debris/crowd/shadow/particle workloads and repeated-recovery cleanup. Do not invent mesh/texture/debris caps from the current model's counts or infer final performance from portable test coverage.

This branch is a throwaway evidence capture: push it, open no PR and never merge it. Publishing the report removes the capture prerequisite only. The performance research decision remains open.

## Original tracker research
Source: https://github.com/Jazenn/Roblox_KFC_Racer/issues/7#issuecomment-6322293701

﻿## Preliminary research progress

Preliminary research supports choosing budgets from a measured representative scene, rather than assigning polygon, texture, spectator, or debris limits now. Roblox recommends selecting a baseline device and checking frame rate and memory throughout development; Studio's device emulator does not accurately represent memory usage. [Design for performance](https://create.roblox.com/docs/performance-optimization/design).

Before resolving this decision, establish:

- A named baseline desktop, hardware, resolution, and intended graphics setting.
- The chosen chassis and approved in-engine van/track visual sample.
- A representative start/finish scene with the player van, populated grandstand, and an empty collision-target van used only as a development fixture.
- A repeatable crash exercising driver ragdoll, detached debris, particles, and checkpoint recovery together.
- Render statistics, client/server physics and script timings, memory, and frame-time behavior during driving, crash peaks, and repeated recovery. Check for accumulating debris, connections, or instances.

Use Render Stats, Developer Console, and MicroProfiler. Investigate physics assembly complexity, precise mesh collisions, spectator animation, draw calls, shadows, and particle overdraw. Roblox recommends simple collisions, anchored scenery, reuse of identical mesh assets, and avoiding unnecessary Humanoids for stationary spectators. [Performance guidance](https://create.roblox.com/docs/performance-optimization/improve).

Check the visual sample at multiple graphics settings; SurfaceAppearance quality depends on device and graphics level. [SurfaceAppearance](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance).

**Status:** Preliminary only; still blocked by [Choose the chassis through a driving and crash prototype](https://github.com/Jazenn/Roblox_KFC_Racer/issues/2) and [Approve the van and circuit visual direction](https://github.com/Jazenn/Roblox_KFC_Racer/issues/3). No numerical budgets or measured acceptance thresholds are established.

**Research artifact capture blocker:** The local repository has no initial commit, so the required throwaway research branch and committed Markdown artifact cannot currently be created. Findings are preserved here pending that prerequisite; no owner setup files were committed and this ticket remains open.
