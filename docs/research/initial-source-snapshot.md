# Initial source snapshot for owner review

Prepared for [Enable durable research artifact capture](https://github.com/Jazenn/Roblox_KFC_Racer/issues/9). No commit, staging or push has been performed.

## Proposed capture

Create an initial main-branch source snapshot of exactly the files below, then push main to the existing origin (Jazenn/Roblox_KFC_Racer). Capture the workflow research report with its source context on research/development-workflow, and preliminary performance findings with source context on research/performance-budget. Push the research branches without PRs or merging. Performance findings remain preliminary; publishing does not establish a measured budget.

Include project policy and agent guidance, CI/security configuration, verification scripts, chassis and visual prototype sources/tests/evidence, original reference PNG, retained rejected-prototype provenance, Blender authoring sources and packed project, GLB, artwork/textures, renders and local mesh reconstruction data. Preserve existing evidence limitations, including unverified engine behavior and outdated prototype rollover recovery.

Keep binary assets in ordinary Git for this initial snapshot; the largest current file is about 7.9 MB. No LFS migration, GitHub release, purchase or asset publication is proposed. Revisit storage if asset growth warrants it.

Exclude .git internals, .tools, build outputs, coverage reports, Python bytecode/cache and the .blend1 backup. Excluded files remain on disk. No credentials or machine configuration are intended for publication.

## Exact proposed file set
Proposed file count: 140. Existing payload bytes excluding this review document: 23915475. No files are staged.

| Path | Bytes |
| --- | ---: |
| .agents/agents/test-engineer.md | 3515 |
| .agents/skills/constraint-driven-development/references/floor-guard.md | 10681 |
| .agents/skills/constraint-driven-development/SKILL.md | 21008 |
| .github/agents/test-engineer.agent.md | 3351 |
| .github/workflows/chassis-prototype.yml | 2825 |
| .github/workflows/constraints.yml | 1270 |
| .gitignore | 105 |
| AGENTS.md | 473 |
| CLAUDE.md | 81 |
| CONSTRAINTS.md | 9775 |
| docs/agents/domain.md | 705 |
| docs/agents/issue-tracker.md | 1249 |
| docs/agents/triage-labels.md | 483 |
| docs/research/initial-source-snapshot.md | this review document |
| docs/research/roblox-development-workflow.md | 12119 |
| GLOSSARY.md | 680 |
| kfc_racer_van.png | 30841 |
| prototypes/chassis/default.project.json | 640 |
| prototypes/chassis/EVIDENCE.md | 17554 |
| prototypes/chassis/measurements/steering-response.json | 968 |
| prototypes/chassis/README.md | 6196 |
| prototypes/chassis/src/Actuators.lua | 3269 |
| prototypes/chassis/src/Build.lua | 10158 |
| prototypes/chassis/src/Client.client.lua | 5124 |
| prototypes/chassis/src/DriveModel.lua | 3978 |
| prototypes/chassis/src/Server.server.lua | 11981 |
| prototypes/chassis/tests/drive.test.lua | 3413 |
| prototypes/chassis/tests/impact.test.lua | 1439 |
| prototypes/chassis/tests/input-response.client.lua | 2043 |
| prototypes/chassis/tests/steering.test.lua | 5081 |
| prototypes/chassis/tests/STUDIO.md | 4946 |
| prototypes/visual/assets/KombiSource.rbxm | 48109 |
| prototypes/visual/blender/build_reference_van.py | 15295 |
| prototypes/visual/blender/export/body_front.png | 9616 |
| prototypes/visual/blender/export/body_left.png | 142718 |
| prototypes/visual/blender/export/body_right.png | 142732 |
| prototypes/visual/blender/export/body_roof.png | 148282 |
| prototypes/visual/blender/export/colonel-raster.png | 42296 |
| prototypes/visual/blender/export/left_front.png | 1650033 |
| prototypes/visual/blender/export/meshdata/0001.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0002.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0003.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0004.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0005.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0006.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0007.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0008.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0009.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0010.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0011.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0012.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0013.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0014.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0015.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0016.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0017.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0018.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0019.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0020.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0021.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0022.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0023.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0024.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0025.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0026.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0027.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0028.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0029.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0030.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0031.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0032.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0033.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0034.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0035.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0036.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0037.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0038.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0039.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0040.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0041.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0042.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0043.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0044.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0045.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0046.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0047.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0048.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0049.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0050.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0051.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0052.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0053.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0054.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0055.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0056.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0057.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0058.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0059.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0060.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0061.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0062.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0063.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0064.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0065.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0066.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0067.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0068.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0069.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0070.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0071.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0072.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0073.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0074.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0075.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0076.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0077.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0078.txt | 100000 |
| prototypes/visual/blender/export/meshdata/0079.txt | 68104 |
| prototypes/visual/blender/export/paint_metalness.png | 92 |
| prototypes/visual/blender/export/paint_roughness.png | 92 |
| prototypes/visual/blender/export/rear.png | 1569603 |
| prototypes/visual/blender/export/reference_van.mesh.json | 7868104 |
| prototypes/visual/blender/export/reference_van_v3.blend | 617212 |
| prototypes/visual/blender/export/reference_van_v3.glb | 1889552 |
| prototypes/visual/blender/export/right_front.png | 1663125 |
| prototypes/visual/blender/make_livery.py | 5309 |
| prototypes/visual/default.project.json | 457 |
| prototypes/visual/README.md | 6874 |
| prototypes/visual/references/colonel-portrait.svg | 14383 |
| prototypes/visual/src/Kombi.lua | 4603 |
| prototypes/visual/src/Preview.client.lua | 1890 |
| prototypes/visual/src/ReferenceVan.lua | 4071 |
| prototypes/visual/src/Scene.lua | 8346 |
| prototypes/visual/tests/asset.test.lua | 1019 |
| prototypes/visual/tests/reference_mesh.test.py | 3886 |
| scripts/chassis-coverage.mjs | 1263 |
| scripts/chassis-security-fixtures.mjs | 1554 |
| scripts/floor-guard.mjs | 9479 |
| security/chassis.lua | 522 |
| security/chassis.yml | 903 |

## Review validation

- Gitleaks 8.24.2 downloaded from the official release; ZIP SHA-256 matches its published checksum.
- `gitleaks dir --redact --no-banner --exit-code 1 --report-format json --report-path build/initial-snapshot-secrets.json build/initial-snapshot-review`: exit 0, no leaks found across the copied candidate files. This is a file scan, not a history scan; no history exists yet.
- No initial commit, staged files, research branch or remote push exists yet. CI and engine verification are not claimed.
- The existing workflow report's earlier scanner-unavailable observation remains historical; this session provisioned Gitleaks in ignored .tools specifically for this review.
- Proposed publication is a source/evidence snapshot, not a verified release. Only .gitignore and review documentation were changed by this capture task.
