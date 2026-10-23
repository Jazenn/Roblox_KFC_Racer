-- Throwaway Studio size comparison. Run only in the approved scratch place.
-- Question: which uniform van scale reads correctly beside an R15 driver?
local source = workspace:WaitForChild("WorkflowRoundTrip"):WaitForChild("KFC_Reference_Van_v3")
assert(not workspace:FindFirstChild("VanFitPrototype"), "Comparison already exists; preserve owner work")
local sourceCount = #source:GetDescendants()
local sourceFrame, sourceSize = source:GetBoundingBox()
local folder = Instance.new("Folder")
folder.Name = "VanFitPrototype"
folder:SetAttribute("Purpose", "Throwaway static size review; no driving or fit validation")
folder.Parent = workspace
local function block(parent, name, size, frame, color)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
    p.Anchored, p.CanCollide = true, false
    p.Parent = parent
    return p
end
local function caption(parent, position, text)
    local anchor = block(parent, "CaptionAnchor", Vector3.new(.1,.1,.1), CFrame.new(position), Color3.new(1,1,1))
    anchor.Transparency = 1
    local gui = Instance.new("BillboardGui")
    gui.Size, gui.AlwaysOnTop = UDim2.fromOffset(360, 85), true
    gui.Parent = anchor
    local label = Instance.new("TextLabel")
    label.Size, label.BackgroundTransparency = UDim2.fromScale(1,1), .15
    label.BackgroundColor3, label.TextColor3 = Color3.fromRGB(20,24,30), Color3.new(1,1,1)
    label.TextSize, label.TextWrapped, label.Text = 17, true, text
    label.Parent = gui
end
local rows = {}
local desc = Instance.new("HumanoidDescription")
local template = game:GetService("Players"):CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
desc:Destroy()
for index, factor in ipairs({3, 1/.28, 4, (1/.28+4)/2}) do
    local x, z, ground = 1068 + (index-1)*24, 50, 8
    local sample = Instance.new("Model")
    sample.Name = ({"A_Compact", "B_SourceMeters", "C_Large", "D_Midpoint"})[index]
    sample.Parent = folder
    block(sample, "ReviewPad", Vector3.new(22,.2,30), CFrame.new(x,ground-.1,z), Color3.fromRGB(73,78,84))
    local van = source:Clone()
    van.Name = "Van"
    for _,p in ipairs(van:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, true
        end
        assert(not p:IsA("LuaSourceContainer"), "Imported van must be static")
    end
    van:ScaleTo(source:GetScale()*factor)
    local cf, size = van:GetBoundingBox()
    local destination = Vector3.new(x,ground+size.Y/2,z)
    van:PivotTo(CFrame.new(destination-cf.Position)*van:GetPivot())
    van.Parent = sample
    local driver = template:Clone()
    driver.Name = "R15_SizeReference"
    for _,p in ipairs(driver:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored, p.CanCollide = true,false
            if p.Name ~= "HumanoidRootPart" then
                p.Color = string.find(p.Name,"Head") and Color3.fromRGB(235,191,140) or Color3.fromRGB(95,145,185)
            end
        end
    end
    local dcf, ds = driver:GetBoundingBox()
    driver:PivotTo(CFrame.new(Vector3.new(x-size.X/2-2,ground+ds.Y/2,z-3)-dcf.Position)*driver:GetPivot())
    driver.Parent = sample
    caption(sample, Vector3.new(x,ground+size.Y+2,z), string.format("%s | %.2f x %.2f x %.2f studs\nSame R15 driver; static size review", string.sub(sample.Name,1,1),size.X,size.Y,size.Z))
    sample:SetAttribute("UniformScaleFromImport",factor)
    rows[index]={variant=sample.Name,scale=factor,width=size.X,height=size.Y,length=size.Z,driverHeight=ds.Y}
    task.wait()
end
template:Destroy()
assert(#source:GetDescendants()==sourceCount and source:GetBoundingBox()==sourceFrame, "Source changed")
workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(1092,35,4),Vector3.new(1092,13,50))
game:GetService("Selection"):Set({folder})
return game:GetService("HttpService"):JSONEncode(rows)
