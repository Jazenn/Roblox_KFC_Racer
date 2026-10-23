# Studio round-trip evidence

Evidence for [Verify Studio source and asset round trips](https://github.com/Jazenn/Roblox_KFC_Racer/issues/10), 2026-10-23. Partial results; task remains open.

## Authorization and target

The owner explicitly approved an isolated temporary folder in Roblox_KFC_Racer, place 128617506057924, using the existing creator's assets without experience publication. Studio inspection confirmed Edit mode, User creator 2906799966, Studio 0.744.0.7441077. Existing art and chassis were preserved.

## Source iteration

The existing Rojo 7.7.1 process serves `docs/research/fixtures/studio-roundtrip/default.project.json` from this research worktree on 127.0.0.1:34872. The project restricts the place ID and maps only `ServerStorage.WorkflowRoundTrip.Probe`; surrounding instances are ignored. Studio's plugin panel identifies Rojo 7.7.1 and the WorkflowRoundTrip connection.

Before the experiment, disk and Studio both contained `return { revision = "disk-v2" }`. Changing only the disk fixture to `disk-v3` caused the Studio ModuleScript Source to update to `disk-v3`, confirmed by a separate MCP read. No direct Studio source write was used. A subsequent encoding cleanup removed the PowerShell UTF-8 BOM; inspect the final saved source when reopening. This demonstrates disk-to-Studio live source update, not Studio-to-disk synchronization.

The pinned direct Rojo executable successfully built the same project into `build/workflow-source-roundtrip.rbxlx`. That build is separate from the requested save/reopen of the imported-asset sample. It does not prove persistence of Studio-authored content. No game-runtime behavior was added.

## Imported asset inspection

On reconnect, `Workspace.WorkflowRoundTrip.KFC_Reference_Van_v3` already existed. This session did not witness its initial importer interaction or creator selection; the hierarchy and IDs below establish current state, not how it was imported. The original EditableMesh preview remains separately under `Workspace.VisualDirectionPrototype`.

The sample contains 134 MeshParts, no scripts, and no SurfaceAppearance objects. Its bounding box is approximately 2.4401 x 2.1269 x 4.9650 studs, centered at (1100, 9.0665, -0.0025). Scale/orientation have not been accepted as production-correct.

| Part | Permanent mesh | Permanent color texture |
| --- | --- | --- |
| Body_Left | 106974064822164 | 109974726320808 |
| Body_Right | 116223091573365 | 114157020033163 |
| Windshield | 80717835923115 | None |
| Tire | 101780566735479 | None |

The left/right body parts have nonempty TextureID values. An exterior Studio capture shows livery, but the tires, windows and other untextured components appear gray. Sampled parts all have Color approximately (0.6392, 0.6353, 0.6471), Plastic material and no SurfaceAppearance. The windshield is opaque and not double-sided. Opaque glazing alone is not a defect: the GLB's Glass material also has alpha 1. The missing intended dark glass/rubber colors are a fidelity failure.

Read-only GLB inspection confirms distinct baseColorFactor values for Rubber, Glass, Trim and other untextured materials, plus textured Paint_Left/Paint_Right/Paint_Front/Paint_Roof materials. This narrows the observed discrepancy to the imported material result; it does not identify its cause or prove an importer limitation. Do not fix the sample by inventing a new art direction or claim the preview renderer is a permanent-import substitute.

## Remaining observed evidence

- Save the isolated sample locally, reopen it, and check source plus mesh/texture persistence without local reconstruction or an HTTP asset server. This is pending: Studio File-menu automation did not open a usable save dialog. The owner was given the exact local scratch path and requested save/open action.
- Verify normal importer settings, intended creator/access, correct units/axes, both exterior sides, and material transfer. Initial import settings were not observed in this session.
- Exercise controlled reimport of the same source and confirm object matching without duplicates or altered collision ownership. Not performed.
- Record cleanup of owned fixtures after persistence/reimport evidence is captured. Do not delete the approved preview, imported sample or unsaved owner work.

The task cannot close on the successful source update alone. Material fidelity, reopen and reimport remain unverified or failing as stated above; no performance, engine coverage or production-readiness claim follows.

## Checks for this capture

Run from the research worktree: `node scripts/floor-guard.mjs --base HEAD` passed; `git diff --check` passed; `../../.tools/luau-0.743/luau-compile.exe --null docs/research/fixtures/studio-roundtrip/Probe.lua` passed; `../../.tools/gitleaks-8.24.2/gitleaks.exe dir --redact --no-banner docs/research` reported no findings. The source fixture is a static data module, not a gameplay behavior change. Final Studio inspection confirmed the BOM-free `disk-v3` source. Live update and CLI build are observed passes; saved-place persistence and reimport have no pass result.
