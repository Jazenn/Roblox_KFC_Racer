-- Scratch-only follow-up for chosen size D. Static datums, not a working chassis.
local sample = workspace:WaitForChild("VanFitPrototype"):WaitForChild("D_Midpoint")
local van = sample.Van
assert(not sample:FindFirstChild("ChassisFitDatums"), "Fit review already exists")
local manifest = game:GetService("HttpService"):JSONDecode(van:GetAttribute("WorkflowBaseColorManifest"))
local colors = sample.R15_SizeReference:FindFirstChildOfClass("BodyColors")
if colors then
    colors.HeadColor3 = Color3.fromRGB(235,191,140)
    colors.TorsoColor3 = Color3.fromRGB(95,145,185)
    colors.LeftArmColor3, colors.RightArmColor3 = colors.TorsoColor3, colors.TorsoColor3
    colors.LeftLegColor3, colors.RightLegColor3 = Color3.fromRGB(45,65,85), Color3.fromRGB(45,65,85)
end
local materialCounts = {}
local paintCount = 0
for _,p in ipairs(van:GetDescendants()) do
    if p:IsA("MeshPart") then
        local record = assert(manifest.meshes[p.Name], "Missing source material")
        local mat = record.material
        materialCounts[mat] = (materialCounts[mat] or 0)+1
        if string.sub(mat,1,6)=="Paint_" then
            p.Material = Enum.Material.SmoothPlastic
            if p.TextureID~="" then
                assert(not p:FindFirstChildOfClass("SurfaceAppearance"), "Unexpected existing PBR")
                local appearance = Instance.new("SurfaceAppearance")
                appearance.Name = "PrototypeSourcePaintPBR"
                appearance.ColorMap = p.TextureID
                appearance.RoughnessMap = "rbxassetid://132458418620921"
                appearance.MetalnessMap = "rbxassetid://112811015235632"
                appearance.Parent = p
                p.TextureID = ""
                p.Color = Color3.new(1,1,1)
                paintCount = paintCount+1
            end
        elseif mat=="Rubber" then
            p.Material = Enum.Material.Rubber
        elseif mat=="Chrome" or mat=="White_Steel" then
            p.Material = Enum.Material.Metal
        else
            p.Material = Enum.Material.SmoothPlastic
        end
        p:SetAttribute("PrototypeSourceMaterial", mat)
    end
end
assert(paintCount==4, "Expected four existing livery textures")
local datums = Instance.new("Folder")
datums.Name = "ChassisFitDatums"
datums.Parent = sample
local frame = van:GetBoundingBox()
local function datum(name, size, cf, color, transparency)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name,size,cf,color
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true,false,false,false
    p.Transparency = transparency
    p.Parent = datums
    return p
end
local tires = {}
for _,name in ipairs({"Tire", "Tire.001", "Tire.002", "Tire.003"}) do
    local tire = assert(van:FindFirstChild(name,true), "Missing wheel")
    tires[#tires+1] = tire
    datum("ProposedMount_"..name,Vector3.new(.18,.18,.18),tire.CFrame,Color3.fromRGB(60,255,140),0)
end
local frontZ = (tires[1].Position.Z+tires[3].Position.Z)/2
local rearZ = (tires[2].Position.Z+tires[4].Position.Z)/2
local wheelY = tires[1].Position.Y
local axleMid = (frontZ+rearZ)/2
-- Original Build.van mounts: X +/-3.65, Z +/-3.7, wheel diameter 2.6.
-- Compare with axle midpoint aligned; do not silently stretch the accepted chassis.
for _,x in ipairs({-3.65,3.65}) do
    for _,z in ipairs({-3.7,3.7}) do
        local p = datum("OriginalChassisWheel",Vector3.new(1.1,2.6,2.6),CFrame.new(frame.Position.X+x,wheelY,axleMid+z),Color3.fromRGB(255,155,30),.55)
        p.Shape = Enum.PartType.Cylinder
    end
end
local result = {
    originalWheelbase=7.4,
    proposedWheelbase=math.abs(rearZ-frontZ),
    originalTrack=7.3,
    proposedTrack=math.abs(tires[1].Position.X-tires[3].Position.X),
    originalWheelDiameter=2.6,
    proposedWheelDiameter=tires[1].Size.Y,
    paintedPBRParts=paintCount,
    sourceMaterialCounts=materialCounts,
    limit="Four livery surfaces use source paint roughness/metalness maps; other surfaces use built-in approximations. No clearcoat equivalence, dynamic fit or handling pass."
}
sample:SetAttribute("FitReview",game:GetService("HttpService"):JSONEncode(result))
return game:GetService("HttpService"):JSONEncode(result)
