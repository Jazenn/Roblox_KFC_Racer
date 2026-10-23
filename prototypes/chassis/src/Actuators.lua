-- Shared physical-wheel commands: local prediction and server validation agree.
local Model = require(script.Parent:WaitForChild("DriveModel"))
local Actuators = {}

function Actuators.bind(model)
    local wheels = {}
    wheels.rollExposure = 0
    wheels.rollClock = os.clock()
    wheels.raycastParams = RaycastParams.new()
    wheels.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    wheels.raycastParams.RespectCanCollide = true
    for _, part in ipairs(model:GetChildren()) do
        if part.Name == "Wheel" and part:IsA("BasePart") then
            local axle = part:FindFirstChild("Axle")
            local hub = axle and axle.Attachment0 and axle.Attachment0.Parent
            if axle and hub and part:GetAttribute("Side") then
                wheels[#wheels + 1] = {
                    part = part,
                    axle = axle,
                    steering = hub:FindFirstChild("SteeringServo"),
                    rear = part:GetAttribute("Rear"),
                    side = part:GetAttribute("Side"),
                }
            end
        end
    end
    return wheels
end

function Actuators.apply(wheels, speed, throttle, steering, handbrake, root)
    local now = os.clock()
    local elapsed = now - wheels.rollClock
    wheels.rollClock = now
    local frontTarget, frontTorque, rearTarget, rearTorque, angle = Model.drive(speed, throttle, steering, handbrake)
    for _, wheel in ipairs(wheels) do
        if wheel.part.Parent and wheel.part:GetAttribute("Attached") then
            local wheelAngle, factor = Model.wheel(angle, wheel.side, wheel.rear)
            local target, torque = frontTarget, frontTorque
            if wheel.rear then
                target, torque = rearTarget, rearTorque
            end
            wheel.axle.AngularVelocity = -target * factor / 1.3
            wheel.axle.MotorMaxTorque = torque
            if wheel.steering then
                wheel.steering.TargetAngle = -wheelAngle
            end
        end
    end
    local loadTransfer = root:FindFirstChild("TurnLoadTransfer")
    if not loadTransfer then
        return
    end
    local velocity = root.AssemblyLinearVelocity
    local roadSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local load = Model.rollLoad(roadSpeed, steering, true)
    local contacts = 0
    if load ~= 0 and root.CFrame.UpVector.Y > 0.5 then
        local excluded = {root.Parent}
        local seat = root.Parent:FindFirstChild("DriverSeat")
        if seat and seat.Occupant then
            excluded[#excluded + 1] = seat.Occupant.Parent
        end
        wheels.raycastParams.FilterDescendantsInstances = excluded
        for _, wheel in ipairs(wheels) do
            if wheel.part.Parent and wheel.part:GetAttribute("Attached") then
                local hit = workspace:Raycast(wheel.part.Position, Vector3.new(0, -1.8, 0), wheels.raycastParams)
                if hit and hit.Normal.Y > 0.5 then
                    contacts = contacts + 1
                end
            end
        end
    end
    wheels.rollExposure, load = Model.rollStep(wheels.rollExposure, roadSpeed, steering, contacts >= 2, elapsed)
    loadTransfer.Torque = Vector3.new(0, 0, load * root.AssemblyMass * workspace.Gravity * 4.6)
end

return Actuators
