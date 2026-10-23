# Reproducible Roblox development workflow

Research for [Establish a reproducible Roblox development workflow](https://github.com/Jazenn/Roblox_KFC_Racer/issues/4), checked 2026-10-23. This is a local research artifact, not a completed game or a verified production pipeline.

## Recommendation

Use repository-owned Luau source and Rojo project files, pinned official Luau CLI for portable logic tests/coverage, Lune for serialized model inspection, and Roblox Studio for engine integration and asset import. Retain the existing constraint, secret and source-security jobs. Do not treat a successful place build or portable coverage as evidence that physics, avatars or a race work in Studio.

This follows the existing implementation rather than introducing another stack. Node is only used by repository verification scripts. No runtime package dependency manager is currently needed; select one and its compatible vulnerability checks when actual dependencies are introduced.

## Local evidence

Commands below were run from the repository root. They used existing tools; no tool installation, source behavior change, commit, branch or issue mutation was performed.

| Command | Observed result |
| --- | --- |
| `rojo --version` | Failed: `ERROR home directory not found` |
| `lune --version` | Failed with the same error |
| `& "$env:USERPROFILE/.rokit/tool-storage/rojo-rbx/rojo/7.7.1/rojo.exe" --version` | Rojo 7.7.1 |
| `& "$env:USERPROFILE/.rokit/tool-storage/lune-org/lune/0.11.0/lune.exe" --version` | lune 0.11.0 |
| `.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua` | 87 assertions passed; coverage.out written |
| `node scripts/chassis-coverage.mjs` | DriveModel: 86/86 instrumented lines, 100%; engine/project runtime explicitly unmeasured |
| Direct Lune binary above, `run prototypes/visual/tests/asset.test.lua` | 304 static parts; mesh data only; no executable code or chassis |
| `python prototypes/visual/tests/reference_mesh.test.py` | Six tests passed |
| Direct Rojo binary above, `build prototypes/chassis/default.project.json --output build/workflow-chassis-check.rbxlx` | Build succeeded |
| Direct Rojo binary above, `build prototypes/visual/default.project.json --output build/workflow-visual-check.rbxlx` | Build succeeded |
| `.tools/luau-0.743/luau-compile.exe --null <each Lua file>` | All 14 files in chassis/visual src/tests compiled |
| `node scripts/floor-guard.mjs --base HEAD` | Clean; the guard handles this unborn repository |
| `git diff --check` | No whitespace findings; untracked files are outside normal Git diff coverage |
| `git rev-parse --verify HEAD` | Failed: no revision exists |
| `uv tool list` | Sandbox cache-lock access denied; approved retry succeeded and listed only blender-mcp |

The PATH commands resolve to `.rokit/bin` shims. Working direct installed executables isolate the observed failure to the launcher path rather than proving Rojo or Lune broken. The exact Rokit/home-discovery root cause was not established, and no HOME/USERPROFILE mutation or launcher repair was made. For this workspace, use the verified direct paths until a separately verified launcher repair is available; portable setup should resolve pinned binaries without embedding this user's absolute path.

Neither `semgrep` nor `gitleaks` resolved on PATH during this session. A fresh security scan is therefore **unverified**, not passing. Prior source scan results are recorded in CONSTRAINTS.md and prototype evidence, but were not repeated here. Installed uv tool inventory is not proof that no cached ephemeral scanner exists.

## Source and Studio ownership

Keep executable source and pure rules on disk as authoritative inputs. Use `rojo serve <project.json>` and the matching Studio plugin for iterative source updates; use `rojo build <project.json> --output <place.rbxlx>` for reproducible place artifacts. Official Rojo documentation supports both workflows. Live synchronization was not exercised in this research session. [Rojo new-game guide](https://rojo.space/docs/v7/getting-started/new-game/)

Avoid editing a Rojo-owned script in Studio and expecting the edit to become disk source automatically. Assign ownership of Studio-authored scenery/terrain and asset snapshots explicitly. Rojo recognizes Lua source, model files and project mappings, but documents real-time limitations for terrain/CSG data and MeshPart.MeshId. Use reviewed model snapshots and fresh builds for those paths rather than claiming every property can live-sync. [Rojo sync details](https://rojo.space/docs/v7/sync-details/)

For the van, retain the Blender project, packed textures and GLB as authoring inputs. Use Studio's normal Importer for permanent uploaded assets; record creator, imported IDs, upload permissions, units, axes and import settings. The Importer supports GLB/PBR and exposes creator/upload options. Choose the intended experience owner or group explicitly; do not infer publication rights from an asset ID. [Roblox Importer](https://create.roblox.com/docs/studio/importer)

Maintain stable unique mesh names and hierarchy for reimport. Reimport updates matching mesh/texture content, but source paths are local and must be configured on another device. Renaming a mesh can create a new object while leaving the old one. Review the imported hierarchy after each reimport and keep collision proxies separate from render meshes. [Roblox reimport](https://create.roblox.com/docs/art/modeling/reimport)

The current EditableMesh-based van reconstruction is an art-preview path, not proof of permanent uploaded mesh persistence. `prototypes/visual/README.md` records the unsuccessful serialization/API attempt and the local mesh-chunk rebuild. Complete and reopen a normal imported-asset sample before declaring that pipeline repeatable across Studio sessions.

Inspect reusable assets before executing their scripts; record provenance and strip unneeded code/chassis from scenery imports. Creator metadata alone does not establish rights to every underlying component. Roblox documents security risks from third-party assets. [Third-party vulnerabilities](https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities)

## Testing, coverage and source security

Use the official Luau CLI 0.743 and existing assertion suite for deterministic driving/input/damage/recovery rules. Its versioned source explicitly implements `--coverage` and coverage.out output. Lune remains useful for model-file checks, but is not intended to execute complete Roblox games. [Luau 0.743 CLI source](https://github.com/luau-lang/luau/blob/0.743/CLI/src/Repl.cpp), [Lune overview](https://lune-org.github.io/docs/)

Preserve the measured 100% DriveModel baseline. The existing coverage parser requires exactly one DriveModel record and rejects uncovered instrumented lines. This measures one portable module; it does not cover Build.lua, client/server integration or physical behavior. When production source is added, establish the required project/changed-line measurement with meaningful scenarios rather than changing the denominator or presenting the portable subset as the whole game.

Use the existing Studio scenarios in `prototypes/chassis/tests/STUDIO.md`, recording expected/observed behavior and the exact revision. Extend them for the newly approved manual rollover reset, checkpoint recovery and ghosting contract: the current prototype's automatic overturned recovery differs from that later design. Engine integration, client/server misuse, avatar fit, ragdoll, camera transitions and stress testing remain separate from CLI tests. No Studio scenarios were rerun here.

Existing CI pins Semgrep 1.182.0 and runs positive/negative fixtures plus source scans. Its three local rules detect dynamic execution, numeric asset requires and runtime asset/network loading. Semgrep lists Lua as experimental; this is not arbitrary typed-Luau support or a complete security policy. Keep the current source subset parsing clean; before adopting typed syntax, demonstrate scanner compatibility and meaningful defect detection, or select an alternative without weakening CONSTRAINTS.md. [Semgrep language support](https://docs.semgrep.dev/supported-languages)

Reproducible configured source-security commands are:

```text
semgrep scan --config security/chassis.yml --strict --metrics off --json security/chassis.lua > build/security-fixture.json
node scripts/chassis-security-fixtures.mjs
semgrep scan --config security/chassis.yml --error --strict --metrics off prototypes/chassis/src prototypes/visual/src
```

Do not interpret fixture scanning alone as source coverage. Preserve fixture validation, parser-error failure and actual-source scanning together. Python authoring code currently has syntax/mesh checks but no separately documented Python security baseline; adding that language to the maintained production workflow requires an applicable scan.

## Client/server boundary

Recommend server ownership of race state, ordered checkpoint acceptance, timer/results, damage transitions and recovery authorization. Clients submit bounded input intentions and handle responsive controls/camera; the server validates identity, types, finite ranges, permission/state and rate limits. Official guidance requires validation of client data. [Client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)

Client physics ownership can improve responsive driving but does not make vehicle movement trusted. Roblox states that the server cannot verify physics calculations from client-owned parts. Input validation alone therefore does not establish cheat-resistant route progress or multiplayer. Verify server-side route plausibility and retain later multiplayer abuse testing as a separate obligation. [Network ownership](https://create.roblox.com/docs/physics/network-ownership)

## CI and capture blockers

The repository defines `.github/workflows/chassis-prototype.yml` and `constraints.yml`: Luau 0.743 logic/compilation, Lune 0.11.0 serialized-asset checks with a pinned archive checksum, Python mesh regressions, Semgrep 1.182.0 fixtures/source scanning, floor checks and Gitleaks 8.24.2 file/history scans. This is configuration evidence, not a successful CI run. There is currently no Rojo build step in the prototype workflow; add and verify a pinned build job when making the workflow executable on a published branch. Luau downloads use a version tag but no archive checksum; stronger download integrity pinning is recommended.

No initial commit exists. A throwaway research branch cannot be based and pushed without first creating reviewed history. Do not commit the owner's untracked workspace solely to bypass that prerequisite. This report is local; no pushed branch or durable remote context artifact is claimed. Keep the workflow research ticket open until required capture is completed.

The prerequisite is tracked by [Enable durable research artifact capture](https://github.com/Jazenn/Roblox_KFC_Racer/issues/9), a native blocking child task of the map.

Remaining concrete work:

1. Review initial repository contents and establish authorized initial history, then capture this research on a pushed throwaway branch with a ticket pointer, without a PR/merge.
2. Run the configured CI jobs and required source/secret checks against actual published source; record success or failures. Confirm branch protection separately if enforcement is claimed.
3. Verify Rojo plugin synchronization and permanent van import/reimport/reopen with intended creator/experience permissions. Retain model provenance and source assets.
4. Establish engine/project measurement and scenarios required by CONSTRAINTS.md; the existing portable baseline remains intact.
5. Before runtime dependencies are introduced, select compatible dependency scanning and version/integrity tracking. None is currently validated for a future Luau package choice.

The documentation supports this workflow recommendation. It does not clear those execution and capture prerequisites or establish final performance budgets.

## Durable capture update

The owner approved the initial source snapshot and publication. Original source context is commit 507bb4c6aabee918b07b7f551a8e54cbff58fa89 on main; the subsequent floor-guard CI repair is captured in this branch's parent history. This report is published on research/development-workflow, with no PR or merge intended. Earlier statements about an unborn HEAD and absent remote capture describe the original research session, not the current capture state.

Gitleaks 8.24.2 was subsequently provisioned from its official checksum-verified release. The reviewed initial file snapshot and initial committed history passed redacted scans. The initial Chassis prototype CI run passed. The initial Constraints job failed because the complete first-push diff exceeded Node's default subprocess output buffer; a regression reproduced that error before the buffer fix and now verifies large clean diffs, violations at the end of a large file and invalid-base failure. CI includes that regression. See the linked run results on the tracker for final post-fix status; no unobserved CI pass is claimed here.

Permanent import/reimport/reopen, live Studio synchronization, engine/project measurement, owner baseline selection and performance measurements remain outstanding. Capturing this report does not implement the later damage/recovery agreement or establish a production-ready workflow.

## Decision-readiness audit (2026-10-23)

The recommended toolchain is sufficiently supported to choose: disk-owned Luau and Rojo project mappings, Rojo 7.7.1 builds and optional live synchronization, Luau 0.743 portable tests/coverage, Lune 0.11.0 serialized-asset inspection, and Studio integration/import verification. This chooses the route; it does not certify the finished game. Rojo explicitly supports both build/open and live-sync workflows, with documented limits for mesh IDs and binary terrain/CSG data. Treat a fresh build/open as the fallback for unsupported live-sync properties. [Rojo workflow](https://rojo.space/docs/v7/getting-started/new-game/), [sync limits](https://rojo.space/docs/v7/sync-details/)

Keep the workflow ticket open for one bounded fact-finding task: [Verify Studio source and asset round trips](https://github.com/Jazenn/Roblox_KFC_Racer/issues/10). Earlier resolution notes explicitly retain these gaps, and a build alone does not prove that a normal imported van survives saving/reopening or that live source synchronization works in this place. This is a narrower prerequisite than delivering the first playable or proving its final runtime coverage.

Fresh read-only evidence supplied by the driving session: the connected Roblox_KFC_Racer place is in Edit mode, place ID 128617506057924, CreatorType User, CreatorId 2906799966. Its scene modules/local mesh chunks and 13 display MeshParts are present; sampled Paint_Left, Trim and Paint_Right MeshParts have empty MeshId strings. That observation supports the existing preview-only limitation; it is not proof that permanent import is impossible. No Studio mutation, import, reimport, save/reopen or live-sync experiment was performed by this audit.

### Bounded prerequisite task and completion evidence

1. Confirm the intended asset creator (the existing user owner or an explicitly chosen group), relevant upload access, and permission for this experience to use restricted assets. Do not silently switch ownership. The Importer exposes Creator, Upload to Roblox and Add to Workspace settings; adding to a saved/published experience can grant that experience access. Record the actual chosen settings and resulting asset IDs. [Importer ownership and access settings](https://create.roblox.com/docs/studio/importer)
2. In an isolated disposable fixture, start the verified Rojo binary with an explicit project path; connect the matching plugin, make a harmless disk-owned fixture change and observe the Studio instance update. Disconnect/reconnect and confirm the disk source remains authoritative. Record CLI/plugin versions, command, mapped paths and observed result. If live sync cannot be made reliable, explicitly choose and demonstrate the already-supported build/open workflow instead of labeling synchronization verified. Do not overwrite the current game scene to run this test. [Rojo build and live-sync procedure](https://rojo.space/docs/v7/getting-started/new-game/)
3. Import a disposable copy of the saved reference van GLB through the normal Importer with the agreed creator/access settings. Record axes/units, hierarchy, mesh/texture IDs and separate render/collision ownership. Check exterior glazing and readable left/right artwork against the approved reference. Save and reopen an isolated sample and verify the geometry/materials still load without the local EditableMesh reconstruction. The normal Importer documents glTF/GLB hierarchy and PBR support; documentation is capability evidence, not this sample's observed result. [Importer](https://create.roblox.com/docs/studio/importer)
4. Reimport one reversible source change while preserving mesh paths/names; observe that the intended mesh/texture updates without unwanted duplicates or altered collision properties. Restore the source/sample and record the result. Configure the local reimport path after reopening when necessary; paths are device-local and are not stored in the place file. [Reimport](https://create.roblox.com/docs/art/modeling/reimport), [official source](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/art/modeling/reimport.md)
5. Link the source revision, fixture/artifact and expected/observed results from the task. Close it only when both the chosen source iteration route and a persistent normal asset round trip have evidence. Failures may expose a new workflow decision; they must not be hidden by marking the preview renderer production-ready.

Completing that task can clear this research decision without claiming the whole game verified. Baseline hardware and representative crash profiling remain owned by the performance-budget decision. Race flow, avatar fit, ejection/ghosting, camera behavior, server misuse tests, final engine/project and changed-line coverage remain explicit implementation/acceptance obligations under CONSTRAINTS.md; they are not silently waived or required to be implemented merely to choose tooling. Before claiming affected production behavior complete, those obligations still have to pass.

The source-security choice remains limited to the tested Lua subset. Current Semgrep documentation still lists Lua as experimental, so typed-Luau migration requires compatibility proof or a different scanner before adoption. Server-side client-input validation remains a required design boundary. [Semgrep language support](https://docs.semgrep.dev/supported-languages), [Roblox client/server validation](https://create.roblox.com/docs/scripting/security/client-server-boundary)

Audit actions were documentation review and this report update only. No game code, asset upload, test thresholds, workflow configuration or tracker state changed. No new engine, performance or security execution pass is claimed.

## Final workflow research audit (2026-10-23)

This section supersedes earlier open-prerequisite/current-state statements; those sections preserve the investigation history. [Verify Studio source and asset round trips](https://github.com/Jazenn/Roblox_KFC_Racer/issues/10) is closed with [observed evidence](studio-roundtrip-evidence.md). Initial history and durable capture exist. [Constraints CI](https://github.com/Jazenn/Roblox_KFC_Racer/actions/runs/39934386291) and [Chassis prototype CI](https://github.com/Jazenn/Roblox_KFC_Racer/actions/runs/39934386251) passed at c052f1e. Those runs do not certify later production behavior.

### Chosen route and ownership

Recommend the toolchain above: disk-owned Luau/Rojo mappings, Rojo CLI/plugin 7.7.1, Luau CLI 0.743 for portable tests/coverage, Lune 0.11.0 for serialized inspection, Studio for engine integration and permanent asset authoring. Live disk-to-Studio synchronization, saved/reopened source, permanent meshes/livery, and same-source reimport now have bounded observations. Keep the direct-binary launcher workaround; the Rokit root cause remains undiagnosed. Preserve the existing security/coverage contract and extend CI with a pinned Rojo build and archive integrity checks when implementing the production workflow. No new runtime dependency is needed for this recommendation.

Blender/GLB, texture inputs and a versioned material manifest own the render asset intent; Studio owns the uploaded IDs and reviewed imported snapshot. Reimport is an authoring operation. Record the source revision/hash, complete device-local configured filename, creator/access, axes, units, preset and resulting IDs with each accepted asset revision. The round-trip sample established only the reported own-account/default settings and a sampled creator check; its truncated UI path is unresolved provenance evidence, not an inferred filename. Keep render geometry separate from collision proxies and inspect third-party scripts/provenance before adoption. [Importer](https://create.roblox.com/docs/studio/importer), [reimport](https://create.roblox.com/docs/art/modeling/reimport)

### Material transfer contract

Raw Default import lost this sample's untextured colors; this is an observed failure with no proven importer root cause. Use the [source-derived manifest and edit-time replay procedure](fixtures/studio-roundtrip/material-replay.md) as the explicit base-color ownership route. Before any application, require the expected source hash and unique complete mesh-name matching; reject missing/duplicate meshes rather than guessing. Convert linear source RGB to sRGB, leave the white-factor livery untinted, and compare every channel afterwards. Repeat the comparison after reimport and save/reopen; apply the source values again if needed. A changed source requires a regenerated reviewed manifest. This is a documented authoring procedure, not an installed automatic replay system. The experiment observed all 134 mapped colors persist after reopen and final same-source reimport without a second application. See the linked evidence for saved-versus-unsaved final ID distinctions.

Base-color replay does not transfer the source's scalar roughness, metalness or layered coat. Direct GLB JSON inspection in this audit found 13 materials, scalar roughness/metalness on each, four base-color textures, and KHR_materials_clearcoat on five paint materials (factor approximately 0.35). No roughness/metalness/normal texture bindings were found on these materials. These are source facts, not evidence those properties reached Studio.

For detailed production materials, author uploaded SurfaceAppearance maps and a source-owned map-to-mesh manifest, assembled in Studio at edit time. Current Roblox documentation lists color, normal, roughness, metalness and emissive maps; it exposes no clearcoat input. Therefore exact transfer of the separate glTF clearcoat layer cannot be promised through that documented interface. Recommend an owner-reviewed roughness/metalness approximation for glossy paint, demonstrated under representative lighting and quality levels; whether it preserves the approved appearance is a human decision. Do not silently drop clearcoat and call it equivalent. [Roblox PBR workflow](https://create.roblox.com/docs/art/modeling/surface-appearance), [SurfaceAppearance API](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance), [Khronos clearcoat extension](https://github.com/KhronosGroup/glTF/tree/main/extensions/2.0/Khronos/KHR_materials_clearcoat)

Implementation should bake scalar roughness/metalness into appropriate grayscale images, preserve UVs and base-color factors, and use OpenGL tangent-space normals when authored. Future glTF packed metal/rough textures need channel separation and factor multiplication rather than assigning the packed RGB image unchanged to each Roblox slot. That recommendation follows glTF's material encoding; it is not a claim that a conversion tool exists or was tested here. For the present scalar-only source, channel extraction is unnecessary. Use uploaded IDs and a saved/reopened/reimported comparison to verify the eventual map assembly. [glTF material encoding](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#materials), [Roblox map conventions](https://create.roblox.com/docs/art/modeling/texture-specifications)

### Units and production acceptance

Recommend standard Roblox units (1 stud = 0.28 m), with explicit importer Scale Unit and axis settings recorded. glTF specifies meter-based linear distances; the Importer defaults its Scale Unit to Studs. These conventions do not prove which settings produced the observed sample. Its measured 2.4401 x 2.1269 x 4.9650 studs is an observation, not an accepted full-size van. Do not rescale the approved chassis by inference from that small import. [Roblox units](https://create.roblox.com/docs/physics/units), [Importer transform/scale settings](https://create.roblox.com/docs/studio/importer), [glTF coordinates and units](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#coordinate-system-and-units)

A bounded HITL Studio prototype should choose production width/height/length and wheelbase relative to the approved chassis and driver avatar, then approve the supported PBR/clearcoat approximation. Its acceptance should include readable exterior livery and glazing, lighting/quality comparisons, permanent map IDs, complete source/settings provenance, and save/reopen/reimport checks. This is the next art decision, not a reason to implement finished materials inside toolchain research. Performance-budget ownership remains separate; representative asset/physics profiles must inform that decision.

The workflow research can resolve the tooling/ownership route while that precise production acceptance question remains visible as a new decision. It cannot claim production material conversion, scale/fit, complete permissions, engine/project coverage, runtime race authority or finished-game verification. These remain implementation and acceptance obligations under CONSTRAINTS.md. No source code, game assets, runtime behavior, quality threshold or CI configuration changed in this audit.
