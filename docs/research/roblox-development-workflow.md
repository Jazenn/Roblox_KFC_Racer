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
