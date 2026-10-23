-- Internal physics experiment. Server validates controls, damage and recovery.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("ChassisPrototype")
local Model = require(Shared:WaitForChild("DriveModel"))
local Actuators = require(Shared:WaitForChild("Actuators"))
local Build = require(script.Parent:WaitForChild("Build"))
local remote = Instance.new("RemoteEvent")
remote.Name = "Controls"
remote.Parent = Shared
local world = Build.world()
local spawnFrame = CFrame.new(0, 6, 50)
local target = Build.van(world, CFrame.new(80, 6, -240) * CFrame.Angles(0, -0.3, 0), "CollisionTarget")
target.model:SetAttribute("Purpose", "Unoccupied collision target")
local van = Build.van(world, spawnFrame, "PlayerVan")
local activeWheels = Actuators.bind(van.model)
local driver
local throttle, steering, handbrake = 0, 0, false
local lastInput = -100
local lastReset = -100
local impactHistory = {}
local lastBodyContact = -100
local damaged = false
local wreckTime
local upsideDownTime = 0
local ragdoll
local telemetryTime = 0
local targetResetTime = 0
local seatedCollisionGroups = {}

local function bindBodyContacts()
    local function touched(other)
        if not other.CanCollide or other:IsDescendantOf(van.model) then
            return
        end
        local character = driver and driver.Character
        if character and other:IsDescendantOf(character) then
            return
        end
        lastBodyContact = os.clock()
    end
    van.root.Touched:Connect(touched)
    for _, panel in ipairs(van.panels) do
        panel.part.Touched:Connect(function(other)
            if panel.joint.Parent then
                touched(other)
            end
        end)
    end
end
bindBodyContacts()

local function setDriverOwnership(owner)
    for _, object in ipairs(van.model:GetDescendants()) do
        if object:IsA("BasePart") then
            object:SetNetworkOwner(owner)
        end
    end
end

local function restoreSeatedCollisions()
    for object, group in pairs(seatedCollisionGroups) do
        if object.Parent then
            object.CollisionGroup = group
        end
    end
    seatedCollisionGroups = {}
end

local function seatDriver()
    task.spawn(function()
        local character = driver and driver.Character
        if not character then
            return
        end
        local root = character:WaitForChild("HumanoidRootPart", 15)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then
            warn("Chassis prototype: avatar rig did not load; respawn the character before driving")
            return
        end
        if driver.Character ~= character or wreckTime or humanoid.Health <= 0 then
            return
        end
        if van.seat.Occupant == humanoid then
            return
        end
        root:SetNetworkOwner(nil)
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                seatedCollisionGroups[object] = object.CollisionGroup
                object.CollisionGroup = "PrototypeSeatedDriver"
            end
        end
        task.wait(0.1)
        if not root.Parent or driver.Character ~= character or wreckTime then
            return
        end
        van.seat:Sit(humanoid)
        if van.seat.Occupant == humanoid then
            van.model:SetAttribute("DriverUserId", driver.UserId)
            setDriverOwnership(driver)
        end
    end)
end

local function restoreDriver()
    if not ragdoll then
        return
    end
    for _, item in ipairs(ragdoll.objects) do
        item:Destroy()
    end
    for _, item in ipairs(ragdoll.motors) do
        item.motor.Enabled = item.enabled
    end
    for _, item in ipairs(ragdoll.parts) do
        item.part.CanCollide = item.collidable
    end
    local humanoid = ragdoll.humanoid
    if humanoid.Parent then
        humanoid.RequiresNeck = ragdoll.requiresNeck
        humanoid.AutoRotate = ragdoll.autoRotate
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    ragdoll = nil
end

local function recover()
    local occupant = van.seat.Occupant
    if occupant then
        occupant.Sit = false
    end
    local seatWeld = van.seat:FindFirstChild("SeatWeld")
    if seatWeld then
        seatWeld:Destroy()
    end
    restoreDriver()
    restoreSeatedCollisions()
    van.model:Destroy()
    van = Build.van(world, spawnFrame, "PlayerVan")
    activeWheels = Actuators.bind(van.model)
    throttle, steering, handbrake = 0, 0, false
    impactHistory = {}
    lastBodyContact = -100
    bindBodyContacts()
    damaged = false
    wreckTime = nil
    upsideDownTime = 0
    seatDriver()
end

local function detachWheel()
    for _, wheel in ipairs(van.wheels) do
        if wheel.attached then
            wheel.attached = false
            wheel.part:SetAttribute("Attached", false)
            wheel.slide:Destroy()
            wheel.spring:Destroy()
            wheel.axle.MotorMaxTorque = 0
            damaged = true
            break
        end
    end
end

local function eject()
    local humanoid = van.seat.Occupant
    if not humanoid then
        return
    end
    local character = humanoid.Parent
    ragdoll = {humanoid = humanoid, requiresNeck = humanoid.RequiresNeck, autoRotate = humanoid.AutoRotate, objects = {}, motors = {}, parts = {}}
    humanoid.RequiresNeck = false
    humanoid.AutoRotate = false
    humanoid.Sit = false
    local seatWeld = van.seat:FindFirstChild("SeatWeld")
    if seatWeld then
        seatWeld:Destroy()
    end
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
            local a = Instance.new("Attachment")
            a.CFrame = object.C0
            a.Parent = object.Part0
            local b = Instance.new("Attachment")
            b.CFrame = object.C1
            b.Parent = object.Part1
            local socket = Instance.new("BallSocketConstraint")
            socket.Attachment0 = a
            socket.Attachment1 = b
            socket.LimitsEnabled = true
            socket.UpperAngle = 45
            socket.TwistLimitsEnabled = true
            socket.TwistLowerAngle = -35
            socket.TwistUpperAngle = 35
            socket.Parent = object.Part0
            local filter = Instance.new("NoCollisionConstraint")
            filter.Part0 = object.Part0
            filter.Part1 = object.Part1
            filter.Parent = object.Part0
            for _, item in ipairs({a, b, socket, filter}) do
                ragdoll.objects[#ragdoll.objects + 1] = item
            end
            ragdoll.motors[#ragdoll.motors + 1] = {motor = object, enabled = object.Enabled}
            object.Enabled = false
        elseif object:IsA("BasePart") then
            ragdoll.parts[#ragdoll.parts + 1] = {part = object, collidable = object.CanCollide}
            object.CanCollide = object.Name ~= "HumanoidRootPart" and not object.Parent:IsA("Accessory")
        end
    end
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        character:PivotTo(van.root.CFrame * CFrame.new(-6, 9, 0))
        root.AssemblyLinearVelocity = van.root.AssemblyLinearVelocity + Vector3.new(-10, 28, 0)
    end
    restoreSeatedCollisions()
end

local function beginRecovery(now, reason)
    if wreckTime then
        return
    end
    wreckTime = now
    van.root.TurnLoadTransfer.Torque = Vector3.zero
    van.model:SetAttribute("DriverUserId", 0)
    setDriverOwnership(nil)
    throttle, steering, handbrake = 0, 0, false
    van.model:SetAttribute("RecoveryLocked", true)
    van.model:SetAttribute("State", reason .. ": mandatory 3-second viewing")
end

local function wreck(now)
    if wreckTime then
        return
    end
    beginRecovery(now, "WRECK")
    detachWheel()
    for index, panel in ipairs(van.panels) do
        if index == 2 or index == 4 then
            panel.joint:Destroy()
            panel.part:ApplyImpulse(Vector3.new(index * 20, 200, 0))
        end
    end
    eject()
    van.model:SetAttribute("State", "WRECK: mandatory 3-second viewing")
end

remote.OnServerEvent:Connect(function(player, command, inputThrottle, inputSteering, inputBrake)
    local now = os.clock()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local isDriver = player == driver and humanoid ~= nil and van.seat.Occupant == humanoid
    if command ~= "drive" and command ~= "reset" then
        return
    end
    local previous = lastInput
    if command == "reset" then
        previous = lastReset
    end
    if not Model.accept(now, previous, isDriver, inputThrottle, inputSteering, inputBrake) then
        return
    end
    if wreckTime then
        return
    end
    if command == "reset" then
        lastReset = now
        recover()
    else
        lastInput = now
        throttle, steering, handbrake = inputThrottle, inputSteering, inputBrake
    end
end)

local function attachPlayer(player)
    if driver then
        return
    end
    driver = player
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not wreckTime then
            seatDriver()
        end
    end)
    if player.Character then
        task.defer(seatDriver)
    end
end
Players.PlayerAdded:Connect(attachPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    attachPlayer(player)
end

RunService.Heartbeat:Connect(function(dt)
    local now = os.clock()
    if wreckTime then
        if Model.canRecover(now, wreckTime) then
            recover()
        end
        return
    end
    local velocity = van.root.AssemblyLinearVelocity
    if not van.seat.Occupant and (van.model:GetAttribute("DriverUserId") or 0) ~= 0 then
        van.model:SetAttribute("DriverUserId", 0)
        setDriverOwnership(nil)
    end
    local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local speed = velocity:Dot(van.root.CFrame.LookVector)
    if now - lastInput > 0.4 or not van.seat.Occupant then
        throttle, steering, handbrake = 0, 0, false
    end
    Actuators.apply(activeWheels, speed, throttle, steering, handbrake, van.root)
    local impact = Model.impactStep(impactHistory, now, horizontalSpeed, now - lastBodyContact <= 0.15, damaged)
    if van.root.CFrame.UpVector.Y < 0.1 then
        upsideDownTime = upsideDownTime + dt
    else
        upsideDownTime = 0
    end
    local recoveryReason = Model.recoveryReason(upsideDownTime, van.root.Position.Y)
    if impact == "wreck" then
        wreck(now)
    else
        if impact == "damage" then
            -- Moderate damage is cosmetic so the race can continue on four wheels.
            local door = van.panels[4]
            door.joint:Destroy()
            door.part:ApplyImpulse(van.root.CFrame.RightVector * -120 + Vector3.new(0, 80, 0))
            damaged = true
        end
        if recoveryReason then
            beginRecovery(now, string.upper(recoveryReason) .. " RECOVERY")
        end
    end
    telemetryTime = telemetryTime + dt
    targetResetTime = targetResetTime + dt
    if telemetryTime >= 0.1 then
        telemetryTime = 0
        van.model:SetAttribute("Speed", math.floor(horizontalSpeed))
        if not wreckTime then
            local state = "DRIVING"
            if damaged then
                state = "DAMAGED: body part detached"
            end
            van.model:SetAttribute("State", state)
        end
    end
    if targetResetTime >= 40 then
        targetResetTime = 0
        target.model:Destroy()
        target = Build.van(world, CFrame.new(80, 6, -240) * CFrame.Angles(0, -0.3, 0), "CollisionTarget")
    end
end)
