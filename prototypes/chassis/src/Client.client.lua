-- Throwaway test HUD and immediate, locally predicted keyboard controls.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("ChassisPrototype")
local Model = require(shared:WaitForChild("DriveModel"))
local Actuators = require(shared:WaitForChild("Actuators"))
local remote = shared:WaitForChild("Controls")
local hud = Instance.new("ScreenGui")
hud.Name = "ChassisPrototypeHUD"
hud.ResetOnSpawn = false
hud.Parent = player:WaitForChild("PlayerGui")
local caption = Instance.new("TextLabel")
caption.Size = UDim2.new(1, -40, 0, 98)
caption.Position = UDim2.fromOffset(20, 20)
caption.BackgroundColor3 = Color3.fromRGB(20, 23, 29)
caption.BackgroundTransparency = 0.12
caption.TextColor3 = Color3.new(1, 1, 1)
caption.TextSize = 19
caption.Font = Enum.Font.GothamMedium
caption.Parent = hud
local held = {}
local focused = true
local lastSend = -100
local lastVan
local boundVan
local wheels = {}
local driveKeys = {
    W = true, A = true, S = true, D = true,
    Up = true, Left = true, Down = true, Right = true, Space = true,
}

local function context()
    local world = workspace:FindFirstChild("ChassisPrototypeWorld")
    local van = world and world:FindFirstChild("PlayerVan")
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seat = van and van:FindFirstChild("DriverSeat")
    if not seat or not humanoid or not van.PrimaryPart then
        return
    end
    local state = van:GetAttribute("State") or "SETTLING"
    local isWreck = van:GetAttribute("RecoveryLocked") == true or string.find(state, "WRECK", 1, true) ~= nil
    return van, humanoid, seat, isWreck, state
end

local function controls()
    if not focused or UserInputService:GetFocusedTextBox() then
        return 0, 0, false
    end
    local throttle, steering = Model.axes(held.W or held.Up, held.S or held.Down,
        held.A or held.Left, held.D or held.Right)
    return throttle, steering, held.Space == true
end

local function predictAndSend(command, forceSend)
    local van, humanoid, seat, isWreck = context()
    if not van or isWreck or seat.Occupant ~= humanoid then
        return
    end
    local throttle, steering, handbrake = controls()
    if van ~= boundVan or #wheels < 4 then
        boundVan = van
        wheels = Actuators.bind(van)
    end
    if van:GetAttribute("DriverUserId") == player.UserId then
        local speed = van.PrimaryPart.AssemblyLinearVelocity:Dot(van.PrimaryPart.CFrame.LookVector)
        Actuators.apply(wheels, speed, throttle, steering, handbrake, van.PrimaryPart)
    end
    local now = os.clock()
    if forceSend or now - lastSend >= 0.05 then
        remote:FireServer(command, throttle, steering, handbrake)
        lastSend = now
    end
end

ContextActionService:BindActionAtPriority("PrototypeHandbrake", function()
    local van, humanoid, seat, isWreck = context()
    if van and not isWreck and seat.Occupant == humanoid then
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.KeyCode.Space)

UserInputService.InputBegan:Connect(function(input, processed)
    local key = input.KeyCode.Name
    if UserInputService:GetFocusedTextBox() then
        return
    end
    if key == "Space" then
        local van, humanoid, seat = context()
        if not van or seat.Occupant ~= humanoid then
            return
        end
    elseif processed then
        return
    end
    if driveKeys[key] then
        held[key] = true
        predictAndSend("drive", true)
    elseif key == "R" then
        predictAndSend("reset", true)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode.Name
    if driveKeys[key] then
        held[key] = nil
        predictAndSend("drive", true)
    end
end)
UserInputService.WindowFocusReleased:Connect(function()
    focused = false
    held = {}
    predictAndSend("drive", true)
end)
UserInputService.WindowFocused:Connect(function()
    focused = true
end)
RunService.PreSimulation:Connect(function()
    predictAndSend("drive", false)
end)
RunService.RenderStepped:Connect(function()
    local van, humanoid, seat, isWreck, state = context()
    if not van then
        return
    end
    local camera = workspace.CurrentCamera
    if isWreck then
        camera.CameraSubject = humanoid
    elseif van ~= lastVan or camera.CameraSubject ~= seat then
        camera.CameraSubject = seat
        lastVan = van
    end
    local velocity = van.PrimaryPart.AssemblyLinearVelocity
    local speed = math.floor(Vector3.new(velocity.X, 0, velocity.Z).Magnitude)
    caption.Text = "THROWAWAY CHASSIS EXPERIMENT · physical suspension\n"
        .. tostring(speed) .. " studs/s · " .. state
        .. "\nWASD / arrows: drive   SPACE: rear brake   R: reset   |   Look around with right mouse"
end)
