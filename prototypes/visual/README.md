# Reference-led Blender van prototype

Decision: [Approve the van and circuit visual direction](https://github.com/Jazenn/Roblox_KFC_Racer/issues/3).

The modern box van and subsequent marketplace Kombi were both rejected. The
current original model is built in Blender from the owner's **kfc_racer_van.png**
at the repo root. The actual reference shows a compact sloped-front panel van:
red body, large rear-side Colonel portrait, smaller KFC/food graphics toward the
cab, dark glazing and white wheels. It is not the earlier classic VW proposal.

## Inspect

Studio is in Edit mode, focused on Workspace.VisualDirectionPrototype.RedDeliveryVan
around X=795, Z=28. Both sides were inspected close up in Studio after fixing
inward cab-window normals and mirrored lettering during coordinate conversion.
The paint maps are applied by UV directly to the wheel-arch body meshes, not to
rectangular boards, decals or SurfaceGuis. Accepted driving/chassis code is untouched.

Blender project and self-contained model:
- blender/export/reference_van_v3.blend
- blender/export/reference_van_v3.glb
- blender/export/right_front.png and left_front.png

These files contain the original authored vehicle, with modifiers/UVs/materials
and packed images in the Blender file. The GLB can be imported with Studio's
normal 3D Importer for permanent uploaded mesh assets once the look is approved.

## Rebuild from local data

```powershell
& "$env:USERPROFILE/.rokit/tool-storage/rojo-rbx/rojo/7.7.1/rojo.exe" build prototypes/visual/default.project.json --output build/visual-direction.rbxlx
```

Open that place, then in Studio Edit:

```lua
require(game.ServerStorage.VisualDirectionPrototypeScene).build()
workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(783,8,15),Vector3.new(795,6.2,28))
```

The renderer reads 79 local StringValue chunks from ReferenceVanMeshData and
creates 13 static MeshParts with outward normals and four UV-painted PBR surfaces.
Chunks remain below Studio's 200,000-character StringValue limit. Source geometry
requires no model downloads, HTTP server or external code at build time. Textures
use the project-authored uploaded images listed below. Mesh objects are cleaned
up when their display model is destroyed.

Roblox's CreateAssetAsync mesh-upload API returned "not available yet" in this
session. EditableMesh/object/opaque content did not survive serialization as
permanent mesh content. Consequently no broken .rbxm snapshot is presented as a
saved mesh. The .blend, .glb and checked local geometry chunks are the durable
source, and the Studio preview is reconstructed from them. Existing saved previews
must be removed and rebuilt after reopening; normal Studio GLB import is the later
permanent-asset path. This is an art prototype, not the production asset pipeline.

To rebuild an existing preview, explicitly remove only the owned
Workspace.VisualDirectionPrototype. For changed module sources, use fresh
instances parented in ServerStorage so sibling module references remain valid.

## Authoring

1. Run `python prototypes/visual/blender/make_livery.py` with Pillow available.
2. In a fresh Blender scene/process, run blender/build_reference_van.py.
3. The script creates a new named scene, preserving existing scenes, builds the
   original vehicle, packs paint images, and exports Blender/GLB/mesh data/renders.

The supplied reference PNG is untouched. Colonel artwork comes from the
[standalone Colonel vector](https://cdn.worldvectorlogo.com/logos/kfc-5.svg),
also saved as references/colonel-portrait.svg. Paint maps rasterize that vector
and add original carton/fries graphics and typography. There are separate
left/right layouts with readable lettering, plus roof/front maps. Artwork follows
the actual body geometry and wheel cutouts. No marketplace vehicle or third-party
vehicle script is used in the current model.

Blender coordinates are converted using (-X,Z,Y), a handedness-preserving basis,
to avoid mirrored words. Evaluated geometry includes panel seams, rounded edges,
rubber seals, glazing, grille/headlamp details, mirrors and white ventilated wheels.
Current export: **33,456 triangles**, **13 material groups**, not a measured budget.

Uploaded material images:
- body_left.png: 124178059947244
- body_right.png: 74080269615682
- body_front.png: 74214412134340
- body_roof.png: 110655122093649
- paint_metalness.png: 112811015235632
- paint_roughness.png: 132458418620921

Local import used a temporary loopback-only file server; it was stopped afterward,
and Studio's previous HttpEnabled setting restored. No loopback/network dependency
remains in the scene renderer.

The procedural track sample, fencing, gravel/tire barriers and 42 static spectators
remain unchanged. It is not a complete race track. Cosmetic avatar preview remains
available in src/Preview.client.lua; avatar fit in the new cab still needs review.

## Validation and limits

Commands:
```powershell
python prototypes/visual/tests/reference_mesh.test.py
python -m py_compile prototypes/visual/blender/make_livery.py prototypes/visual/blender/build_reference_van.py
.tools/luau-0.743/luau-compile.exe --null prototypes/visual/src/ReferenceVan.lua
.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua
node scripts/chassis-coverage.mjs
node scripts/floor-guard.mjs --base HEAD
```

Six mesh regressions pass: finite/indexed geometry, outward cab glass, independent
side maps on exterior skins, wheel cutouts without sign boards, readable U direction
(including rejection of the first import's mirrored basis), and chunk reconstruction.
All 87 chassis assertions remain passing with 86/86 portable lines (100%).
Python bytecode and Luau compilation, Rojo build, floor guard and whitespace checks
pass. Semgrep scans nine runtime Lua sources with zero findings, approximately 100%
parsed. Python authoring scripts are syntax checked; no separate Python security
scan is claimed. CI includes the geometry regression command; CI results remain pending.

Studio's fresh local-data rebuild succeeds. Assertions verify 13 anchored,
noncollidable, single-sided mesh parts and four complete PBR paint surfaces, with
no executable scripts, logo boards, SurfaceGuis or Decals. Close-up captures from
both sides show readable branding and both cab windows from outside. Rejected
imports and temporary API probes were cleared. No full performance/engine coverage,
door rigging, crash integration, production polish or revised avatar-fit approval
is claimed. Visual decision remains open for the owner's live response.

Earlier Kombi source/renderer and its serialized-asset regression are retained
as rejected-prototype history; Scene.build does not use them. Their creator/source
provenance is recorded in earlier ticket comments. Repository remains uncommitted;
local capture exists, no pushed throwaway branch is claimed.
