# Studio round-trip evidence

Evidence for [Verify Studio source and asset round trips](https://github.com/Jazenn/Roblox_KFC_Racer/issues/10), 2026-10-23. The bounded source/import/persistence/reimport experiment is complete. Historical progress notes below retain what was unknown at each stage; the final result governs current status. This is not production art or game certification.

## Final result

- Rojo CLI/plugin 7.7.1 disk-to-Studio source synchronization and saved/reopened disk-v3 probe: passed.
- Permanent uploaded meshes/livery persisted in a reopened local scratch file without preview reconstruction: passed.
- Raw Studio Default import/reimport: preserves geometry/livery but loses untextured material colors. This failure is recorded, not declared fixed in the importer.
- Source-derived base-color workaround: all 134 meshes match the GLB manifest before saving, after save/reopen, and after the owner's final reimport. Final comparison: same Model and all 134 MeshPart instances, 134 updated mesh IDs, four updated texture IDs, zero added/removed paths, zero color mismatches and zero CollisionFidelity/CanCollide changes. Source SHA-256 and persisted manifest remain intact.
- Final exterior captures show both livery sides and outside-facing dark glazing: [left](fixtures/studio-roundtrip/images/material-left.png), [right](fixtures/studio-roundtrip/images/material-right.png).
- Owner confirmed own-account creator and Studio Default preset; sampled uploaded asset creator matches User 2906799966. The UI exposes a containing-folder link rather than a copyable full path. Known canonical/research GLB copies are byte-identical; exact configured filepath remains an explicitly recorded UI limitation.

The material route has a reproducible base-color step with observed persistence and reimport, not complete Blender PBR equivalence. Full roughness/metalness maps, clearcoat representation, final scale relative to the chassis/avatar and production visual acceptance remain decisions/acceptance obligations for [Establish a reproducible Roblox development workflow](https://github.com/Jazenn/Roblox_KFC_Racer/issues/4) and the later first-playable contract. The measured 2.4401 x 2.1269 x 4.9650 stud sample is an import-scale observation, not approval of production size. No finished-game work or quality waiver is implied by completing this prerequisite task.

Cleanup/retention: owned temporary source fixture and scratch model are retained as named evidence, not installed as production runtime. Original cloud-place art/chassis/scenery were preserved. The locally saved mapped copy precedes the final reimport, so the final updated IDs are currently in the open scratch window; mapped-color persistence was independently verified from disk before that reimport. Do not discard unsaved owner work or confuse this retained sample with a production asset. No public experience was published.

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

- Save/reopen completed: the owner saved `build/workflow-roundtrip-scratch.rbxl` (759421 bytes) and opened it in a separate Studio window. Independent MCP inspection targeted that named window, in Edit mode with PlaceId 0, rather than the original cloud-place window. The BOM-free `disk-v3` probe, 134 MeshParts with zero empty MeshIds, exact sampled mesh/texture IDs above, bounding box, and zero scripts in the imported model all persisted. No reconstruction script or HTTP asset fetch was run to obtain this result. The original place remained open separately.
- Verify normal importer settings, intended creator/access, correct units/axes, both exterior sides, and material transfer. Initial import settings were not observed in this session.
- The owner invoked Reimport on the selected scratch model. Subsequent inspection confirmed the same Model instance and reimport identifier, 134 meshes before/after, zero added or removed mesh paths, zero CollisionFidelity/CanCollide changes, and all 134 mesh IDs updated. The isolated folder still contains one imported model. Bounding dimensions remain approximately 2.4401 x 2.1269 x 4.9650 studs. This is an observed same-source reimport pass, not merely an unchanged sample. Full post-reimport IDs/properties are captured in `fixtures/studio-roundtrip/reimport-observation.json`.
- Record cleanup of owned fixtures after persistence/reimport evidence is captured. Do not delete the approved preview, imported sample or unsaved owner work.

The task cannot close on the successful source update, reopen and reimport alone. Material fidelity remains failing or unverified as stated above; no performance, engine coverage or production-readiness claim follows.

## Reimport and material diagnostic continuation

The saved model retains `RBX_ReimportId` `0a3c9fd0-5312-419e-a42e-61c5483e982f`. Before reimport, the session recorded an in-memory baseline of mesh count, paths, IDs and CollisionFidelity/CanCollide values and selected only the scratch-copy imported model.

After the confirmed reimport, sampled IDs became: Body_Left mesh 73816781656912 / texture 119806827037540; Body_Right mesh 75293839471767 / texture 98987045748752; Windshield mesh 94272691011906; Tire mesh 123219716654236. Roblox MarketplaceService product information for the new Tire mesh identifies User creator 2906799966, the intended existing owner. This verifies that sampled upload's owner, not every asset's access permissions or unobserved importer settings.

A targeted Studio assertion checks that the imported Tire's RGB channels are below 0.2, consistent with the GLB Rubber baseColorFactor approximately (0.012, 0.015, 0.019). It failed with `Material fidelity FAIL: GLB rubber is dark; imported Tire Color=0.639216, 0.635294, 0.647059`. Repeated inspection returned the same gray value. This isolates a concrete material symptom without modifying the sample.

Hypotheses to distinguish: reimport may restore material transfer; an import setting may control material transfer; or the selected route may require explicit source-derived material mapping. No root cause is established. The automated Alt+Shift+R attempt produced no observable dialog, changed IDs or count; an unchanged sample alone cannot prove reimport ran. The owner was asked to invoke Reimport from the selected model's Explorer menu and report any dialog/error or completion. The saved baseline permits checking duplicate creation and collision-property preservation after a confirmed operation.

Confirmed reimport did not restore the untextured material colors. A bounded scratch-only experiment extracted baseColorFactor for each uniquely named GLB mesh, validated all 134 names before mutation, converted linear RGB to sRGB, and applied the source colors to MeshPart.Color. The dark-rubber assertion then passed with Tire Color approximately (0.1098, 0.1255, 0.1451). A Studio exterior capture showed restored dark tires/glazing, red untextured paint, trim and indicators alongside the retained livery. Original colors were retained in `_G.WorkflowMaterialBaseline` for restoration; this experiment changed only the scratch model and has not been saved/reopened as a production asset. It demonstrates a base-color workaround, not an automated production pipeline or full PBR match: roughness, metalness and clearcoat remain unverified. The original cloud-place preview/model was not modified.

The remaining settings evidence has been requested through Explorer → Reimport → Configure: source filepath, upload creator/target and import preset, without changing them. A missing observed setting must not be inferred from the successful reimport. Task remains open for that capture and a clearly specified material-preserving route; no quality requirement is waived.

## Checks for this capture

### Reproducible base-color continuation

`fixtures/studio-roundtrip/base-color-manifest.json` captures all 134 GLB mesh/material names and linear base colors, with source SHA-256 `3fb6ebab6d60ec881cbb4b702c3705cf41e37b2f7c77dd1ec8b8fa4f81a6ee9c`. The canonical source and all three research/review worktree copies were hash-checked and are identical. This establishes the content identity of the known local candidates without inventing an exact configured path.

The scratch experiment validates one-to-one mesh-name matching before applying any colors, converts linear RGB to sRGB, then checks every RGB channel within 1/255. All 134 comparisons passed. The complete source manifest is also stored on the scratch Model as `WorkflowBaseColorManifest`, enabling a read-only comparison after reopen without relying on session globals. The reproducible procedure and complete check are in `fixtures/studio-roundtrip/material-replay.md`.

The initial automated Ctrl+S attempt did not change the file, so it was not counted. The owner subsequently saved and reopened the mapped scratch copy; the file is now 761666 bytes, last written at 17:11:23 local. The new Studio connection independently passed all 134 source-manifest color comparisons with permanent MeshIds, the exact source hash, the saved reimport identifier, and the BOM-free disk-v3 probe. Tire Color remained approximately (0.1098, 0.1255, 0.1451). This verifies mapped base-color persistence without session globals, reconstruction or a fresh material application. A new pre-reimport baseline records colors, mesh/texture IDs, collisions and instances, and the owner has been asked to reimport once more to check preservation of the mapped colors.

Full PBR remains a distinct limitation, not a reason to call the base-color check failed or to claim polished-material success. Roblox's documented route uses uploaded color/normal/roughness/metalness/emissive maps with SurfaceAppearance; this experiment only maps base color and does not transfer the source's scalar roughness/metalness or clearcoat. The next workflow decision must choose and validate that authoring route before claiming detailed-material fidelity. [PBR textures](https://create.roblox.com/docs/art/modeling/surface-appearance), [SurfaceAppearance API](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance).

Owner settings report: Creator is the owner's account and import preset is Studio Default. The supplied path was `C:\Users\griff\Projects\Roblox Games\Roblox_KFC_Racer\build`, a directory rather than a source filename. A read-only search found reference_van_v3.glb copies under the workflow, performance and initial-snapshot worktrees, but no GLB directly in build. The exact configured source file still needs confirmation; do not silently infer which copy was used.

Run from the research worktree: `node scripts/floor-guard.mjs --base HEAD` passed; `git diff --check` passed; `../../.tools/luau-0.743/luau-compile.exe --null docs/research/fixtures/studio-roundtrip/Probe.lua` passed; `../../.tools/gitleaks-8.24.2/gitleaks.exe dir --redact --no-banner docs/research` reported no findings. The source fixture is a static data module, not a gameplay behavior change. Final Studio inspection confirmed the BOM-free `disk-v3` source. Live update, CLI build and saved-place source/asset persistence are observed passes; same-source reimport passes the observed matching/collision checks. Raw imported material fidelity fails; the scratch base-color mapping passes its targeted check, with full PBR fidelity unverified.
