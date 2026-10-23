-- Run manually in a local Play Client for art review; restart Play to restore driving.
local player=game:GetService("Players").LocalPlayer
local scene=workspace:WaitForChild("VisualDirectionPrototype")
local character=player.Character or player.CharacterAdded:Wait()
local prior=scene:FindFirstChild("AvatarPreview")
assert(not prior,"Avatar preview already exists")
local archivable=character.Archivable
character.Archivable=true
local preview=character:Clone()
character.Archivable=archivable
preview.Name="AvatarPreview"
for _,object in ipairs(preview:GetDescendants()) do
    if object:IsA("LuaSourceContainer") then
        object:Destroy()
    elseif object:IsA("BasePart") then
        object.CanCollide,object.CanTouch,object.CanQuery=false,false,false
    elseif object:IsA("Motor6D") then
        if string.find(object.Name,"Hip",1,true) then
            object.C0=object.C0*CFrame.Angles(-math.pi/2,0,0)
        elseif string.find(object.Name,"Shoulder",1,true) then
            object.C0=object.C0*CFrame.Angles(-.9,0,0)
        end
    end
end
local root=preview:FindFirstChild("HumanoidRootPart")
assert(root,"Avatar preview needs a humanoid root")
root.Anchored=true
local humanoid=preview:FindFirstChildOfClass("Humanoid")
humanoid.EvaluateStateMachine=false
humanoid.PlatformStand=true
humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
preview.Parent=scene
preview:PivotTo(scene:GetAttribute("DriverFrame"))
local controls=player.PlayerScripts:FindFirstChild("ChassisPrototypeClient")
if controls then controls.Enabled=false end
local camera=workspace.CurrentCamera
camera.CameraType=Enum.CameraType.Custom
camera.CameraSubject=scene.RedDeliveryVan:FindFirstChild("Paint_Left")
camera.CFrame=CFrame.lookAt(Vector3.new(775,13,7),Vector3.new(796,7,28))
print("Visual preview: owner's avatar cloned into static display van; restart Play to restore driving")
