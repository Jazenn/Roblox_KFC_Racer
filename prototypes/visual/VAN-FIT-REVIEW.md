# Van size and material prototype

Throwaway Studio evidence for [Approve production van size and material appearance](https://github.com/Jazenn/Roblox_KFC_Racer/issues/11). Work in the owner-approved workflow-roundtrip-scratch.rbxl, never the main place. No runtime game behavior changes.

## Reproduce

Use the existing permanent imported model at Workspace.WorkflowRoundTrip.KFC_Reference_Van_v3, including its source color manifest. Run van-fit-prototype.lua in Studio Edit mode, then van-surface-fit-prototype.lua. Scripts refuse to replace existing owned samples. These are Command Bar/editor fixtures, not production runtime scripts. They create only Workspace.VanFitPrototype and modify its copies. The original import stays intact.

## Owner decision

A is too small. Owner accepted D, the uniform midpoint between B and C: factor 3.7857142857 from the original import, observed approximately 9.2372 wide x 8.0519 high x 18.7336 long studs. Identical R15 reference driver: approximately 5.183 studs high. Preserve the livery and proportions. Source Blender geometry uses X width, -Y front, Z up; imported geometry uses X width, -Z front, Y up. Record explicit source units and apply the chosen factor to the known import rather than silently changing importer units.

## Fit findings and recommendation, awaiting review

Current chassis source Build.van: track 7.3, wheelbase 7.4, wheel diameter 2.6 studs. D art: track approximately 7.4578, wheelbase 11.0921, wheel diameter 2.8166 studs. Static orange cylinders show original chassis wheel datums with axle midpoint aligned; green points show art wheel centers. They are non-colliding visual datums, not an integrated chassis. Recommend moving physical wheel/suspension mounts to the chosen art footprint; preserve the constraint-based approach and retune/retest handling. No dynamic seat, suspension, ground clearance or avatar ejection verification has occurred. Driver seat placement remains to be inspected against the source cabin and representative avatars.

## Material sample, awaiting review

Four textured paint MeshParts use the imported permanent livery texture IDs as SurfaceAppearance.ColorMap, plus the existing source paint maps: roughness 132458418620921 and metalness 112811015235632. Local 16x16 source PNGs are constant RGB 61 and 97 respectively (approximately 0.24 roughness and 0.38 metalness). Other surfaces use retained source base colors with built-in Rubber, Metal or SmoothPlastic approximations. Glazing remains opaque dark blue as authored. Five untextured paint parts do not yet have equivalent scalar PBR maps. No normal map or independent clearcoat layer is claimed.

Roblox's documented [SurfaceAppearance API](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance) exposes color, roughness, metalness and normal maps, with no dedicated clearcoat channel. The paint is a Roblox approximation requiring owner acceptance, not exact Blender shading equivalence.

Reimport ownership: keep source GLB/material manifest authoritative, replay colors by unique mesh name and reapply reviewed PBR assignments after import; validate names/counts before mutation. Existing evidence proves base-color persistence but does not prove these new PBR assignments survive reimport. That remains an explicit integration check.

## Checks and limits

Both fixture scripts compiled with Luau 0.743. Studio execution succeeded: three initial size variants, then D, with original source count/frame unchanged; all 134 mesh names matched the source manifest; exactly four paint PBR assignments made. Floor and whitespace checks passed. No portable-rule behavior changed; these editor fixtures do not establish engine/project coverage or performance. The screenshot review occurred in existing daylight at ClockTime 14; lighting was not changed. No driving, save/reopen of new fixture, PBR reimport or performance pass is claimed.

Ticket remains open for material feedback and cabin/chassis fit decisions. This branch is a prototype capture, not a PR or merge.
