# Base-color experiment replay

This is an authoring experiment, not a runtime script or complete PBR pipeline. Use only the isolated `Workspace.WorkflowRoundTrip.KFC_Reference_Van_v3` in the scratch place. Preserve production art. The accompanying `base-color-manifest.json` contains source GLB linear RGB, material names, mesh names and SHA-256.

To reproduce on a fresh raw import, decode the manifest JSON through HttpService:JSONDecode, match MeshPart.Name to manifest.meshes, and reject missing or duplicate names before changing anything. Require exactly 134 matches for this snapshot. Convert each channel to sRGB using `12.92*c` for `c <= 0.0031308`, otherwise `1.055*c^(1/2.4)-0.055`; set MeshPart.Color to that result. Do not tint the textured livery: its manifest base color is white. Do not change MeshId, TextureID, hierarchy, transforms or collisions. Store the JSON in the imported model's `WorkflowBaseColorManifest` attribute so the following independent check is replayable after save/reopen and reimport. The attribute is diagnostic metadata; no game script executes it.

In the scratch place's edit-time command bar, this read-only check validates every part against the persisted source manifest:

```lua
local model = workspace.WorkflowRoundTrip.KFC_Reference_Van_v3
local manifest = game:GetService("HttpService"):JSONDecode(
    assert(model:GetAttribute("WorkflowBaseColorManifest"), "No persisted manifest")
)
local function srgb(c)
    if c <= 0.0031308 then return 12.92 * c end
    return 1.055 * c ^ (1 / 2.4) - 0.055
end
local seen = {}
local count = 0
for _, part in ipairs(model:GetDescendants()) do
    if part:IsA("MeshPart") then
        local row = assert(manifest.meshes[part.Name], "Unknown mesh " .. part.Name)
        assert(not seen[part.Name], "Duplicate mesh " .. part.Name)
        seen[part.Name] = true
        local c = row.baseColor
        local expected = Color3.new(srgb(c[1]), srgb(c[2]), srgb(c[3]))
        assert(math.abs(part.Color.R - expected.R) <= 1 / 255
            and math.abs(part.Color.G - expected.G) <= 1 / 255
            and math.abs(part.Color.B - expected.B) <= 1 / 255,
            "Base color mismatch " .. part.Name)
        assert(part.MeshId ~= "", "No permanent mesh " .. part.Name)
        count += 1
    end
end
for name in pairs(manifest.meshes) do
    assert(seen[name], "Missing mesh " .. name)
end
assert(count == 134, "Unexpected mesh count")
print("Source base colors and permanent meshes verified:", count, manifest.sha256)
```

Expected red result on raw default import: base color mismatch on untextured parts. Expected green after mapping: 134 matches. The earlier tire-only check was run and failed before mapping, then passed after mapping. The complete 134-part color comparison passed in the live scratch model; save/reopen and post-reimport repetitions must have separately recorded observed results before claiming they pass.

This checks base color and permanent mesh presence only. It does not assert roughness, metalness, clearcoat, texture rendering, scale, collision correctness or visual acceptance. Those need separate checks. A documented base-color workaround does not waive the approved detailed-material direction.
