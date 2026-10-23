-- Throwaway mechanical chassis and internal test fixtures, not the finished track.
local Build = {}
local gray = Color3.fromRGB(55, 59, 65)
local red = Color3.fromRGB(190, 35, 39)

local function part(parent, name, size, frame, color, anchored)
    local object = Instance.new("Part")
    object.Name = name
    object.Size = size
    object.CFrame = frame
    object.Color = color
    object.Anchored = anchored
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.Parent = parent
    return object
end

local function weld(a, b)
    local joint = Instance.new("WeldConstraint")
    joint.Part0 = a
    joint.Part1 = b
    joint.Parent = b
    return joint
end

local function attachment(parent, position, axis, secondary)
    local object = Instance.new("Attachment")
    object.Position = position
    object.Axis = axis
    object.SecondaryAxis = secondary
    object.Parent = parent
    return object
end

local function join(parent, className, a, b)
    local constraint = Instance.new(className)
    constraint.Attachment0 = a
    constraint.Attachment1 = b
    constraint.Parent = parent
    return constraint
end

local function noCollision(a, b)
    local constraint = Instance.new("NoCollisionConstraint")
    constraint.Part0 = a
    constraint.Part1 = b
    constraint.Parent = b
end

local function label(parent, position, text)
    local post = part(parent, "TestMarker", Vector3.new(1, 8, 1), CFrame.new(position), gray, true)
    post.CanCollide = false
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(350, 68)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.MaxDistance = 300
    billboard.Parent = post
    local caption = Instance.new("TextLabel")
    caption.Size = UDim2.fromScale(1, 1)
    caption.BackgroundColor3 = Color3.fromRGB(19, 22, 28)
    caption.BackgroundTransparency = 0.15
    caption.TextColor3 = Color3.new(1, 1, 1)
    caption.Font = Enum.Font.GothamBold
    caption.TextSize = 19
    caption.Text = text
    caption.Parent = billboard
end

function Build.world()
    assert(not workspace:FindFirstChild("ChassisPrototypeWorld"), "Prototype world already exists")
    local physics = game:GetService("PhysicsService")
    for _, group in ipairs({"PrototypeVan", "PrototypeSeatedDriver"}) do
        if not physics:IsCollisionGroupRegistered(group) then
            physics:RegisterCollisionGroup(group)
        end
    end
    physics:CollisionGroupSetCollidable("PrototypeVan", "PrototypeSeatedDriver", false)
    physics:CollisionGroupSetCollidable("PrototypeSeatedDriver", "PrototypeSeatedDriver", false)
    local world = Instance.new("Folder")
    world.Name = "ChassisPrototypeWorld"
    world.Parent = workspace
    local ground = part(world, "Asphalt", Vector3.new(500, 2, 600), CFrame.new(0, 1, -150), gray, true)
    ground.Material = Enum.Material.Asphalt
    ground.CustomPhysicalProperties = PhysicalProperties.new(1, 0.85, 0.05)
    for _, x in ipairs({-25, 25}) do
        part(world, "LaneLine", Vector3.new(0.35, 0.03, 370), CFrame.new(x, 2.02, -120), Color3.new(1, 1, 1), true).CanCollide = false
    end
    for index = 1, 24 do
        local color = Color3.new(1, 1, 1)
        if index % 2 == 0 then
            color = red
        end
        local kerb = part(world, "Kerb", Vector3.new(3, 0.4, 5), CFrame.new(22, 2.2, -index * 5), color, true)
        kerb.Material = Enum.Material.Concrete
    end
    for index = 1, 5 do
        local x = -9
        if index % 2 == 0 then
            x = 9
        end
        part(world, "SlalomMarker", Vector3.new(1.2, 3, 1.2), CFrame.new(x, 3.5, -index * 24), Color3.fromRGB(255, 155, 45), true)
    end
    local ramp = Instance.new("WedgePart")
    ramp.Name = "Jump"
    ramp.Size = Vector3.new(26, 8, 42)
    ramp.CFrame = CFrame.new(-90, 6, -120) * CFrame.Angles(0, math.pi, 0)
    ramp.Color = gray
    ramp.Material = Enum.Material.Asphalt
    ramp.Anchored = true
    ramp.Parent = world
    part(world, "ImpactWall", Vector3.new(65, 12, 4), CFrame.new(0, 8, -325), Color3.fromRGB(155, 160, 167), true)
    for index = 1, 10 do
        local tire = part(world, "TireWall", Vector3.new(4, 4, 4), CFrame.new(70 + index * 4, 4, -270), Color3.fromRGB(24, 25, 27), true)
        tire.Shape = Enum.PartType.Cylinder
        tire.CFrame = tire.CFrame * CFrame.Angles(0, 0, math.pi / 2)
        tire.CustomPhysicalProperties = PhysicalProperties.new(1, 0.9, 0.12)
    end
    label(world, Vector3.new(-34, 7, 40), "CHASSIS EXPERIMENT\nWASD / arrows · Space brake · R reset")
    label(world, Vector3.new(32, 7, -35), "1  STEERING + KERBS")
    label(world, Vector3.new(-112, 7, -85), "2  JUMP\nApproach toward the far wall")
    label(world, Vector3.new(45, 7, -270), "3  WALL + EMPTY VAN")
    return world
end

function Build.van(parent, frame, name)
    local model = Instance.new("Model")
    model.Name = name
    local root = part(model, "Chassis", Vector3.new(6, 1.1, 11), frame, gray, false)
    root.CustomPhysicalProperties = PhysicalProperties.new(2.2, 0.5, 0.02)
    model.PrimaryPart = root
    local loadTransfer = Instance.new("Torque")
    loadTransfer.Name = "TurnLoadTransfer"
    loadTransfer.Attachment0 = attachment(root, Vector3.zero, Vector3.xAxis, Vector3.yAxis)
    loadTransfer.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    loadTransfer.Torque = Vector3.zero
    loadTransfer.Parent = root
    local panels = {}
    local function panel(panelName, size, offset, color)
        local object = part(model, panelName, size, frame * CFrame.new(offset), color, false)
        object.Massless = true
        local joint = weld(root, object)
        panels[#panels + 1] = {part = object, joint = joint}
        return object
    end
    panel("Cargo", Vector3.new(5.8, 5, 6.5), Vector3.new(0, 3, 1.7), Color3.fromRGB(235, 235, 226))
    panel("Roof", Vector3.new(6.1, 0.35, 10.5), Vector3.new(0, 5.65, 0), red)
    panel("Front", Vector3.new(5.8, 1.8, 0.5), Vector3.new(0, 1.5, -5), red)
    panel("DoorLeft", Vector3.new(0.3, 3.6, 3.4), Vector3.new(-2.9, 2.7, -3.3), Color3.fromRGB(240, 240, 230))
    panel("DoorRight", Vector3.new(0.3, 3.6, 3.4), Vector3.new(2.9, 2.7, -3.3), Color3.fromRGB(240, 240, 230))
    local windshield = panel("Windshield", Vector3.new(5.1, 2.3, 0.15), Vector3.new(0, 4.25, -4.95), Color3.fromRGB(76, 131, 149))
    windshield.Transparency = 0.55
    windshield.CanCollide = false
    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriverSeat"
    seat.Size = Vector3.new(2, 0.5, 2)
    seat.CFrame = frame * CFrame.new(-1.25, 1.2, -3.1)
    seat.Massless = true
    seat.CanCollide = false
    seat.HeadsUpDisplay = false
    seat.Parent = model
    weld(root, seat)
    local wheels = {}
    local up = Vector3.new(0, 1, 0)
    local right = Vector3.new(1, 0, 0)
    for _, z in ipairs({-3.7, 3.7}) do
        for _, x in ipairs({-3.65, 3.65}) do
            local mount = Vector3.new(x, -0.2, z)
            local wheelFrame = frame * CFrame.new(mount - Vector3.new(0, 1.65, 0))
            local carrier = part(model, "SuspensionCarrier", Vector3.new(1, 1, 1), wheelFrame, gray, false)
            carrier.Transparency = 1
            carrier.CanCollide = false
            carrier.CustomPhysicalProperties = PhysicalProperties.new(3, 0.3, 0)
            local hub = part(model, "SteeringHub", Vector3.new(1, 1, 1), wheelFrame, gray, false)
            hub.Transparency = 1
            hub.CanCollide = false
            hub.CustomPhysicalProperties = PhysicalProperties.new(3, 0.3, 0)
            local a = attachment(root, mount, up, right)
            local b = attachment(carrier, Vector3.zero, up, right)
            local slide = join(carrier, "PrismaticConstraint", a, b)
            slide.LimitsEnabled = true
            slide.LowerLimit = -2.25
            slide.UpperLimit = -0.65
            local spring = join(carrier, "SpringConstraint", a, b)
            spring.FreeLength = 2.15
            spring.Stiffness = 19000
            spring.Damping = 1400
            spring.Visible = true
            spring.Radius = 0.16
            local steering
            if z < 0 then
                steering = join(hub, "HingeConstraint", attachment(carrier, Vector3.zero, up, right), attachment(hub, Vector3.zero, up, right))
                steering.Name = "SteeringServo"
                steering.ActuatorType = Enum.ActuatorType.Servo
                steering.ServoMaxTorque = 12000
                steering.AngularSpeed = 3
                steering.AngularResponsiveness = 40
                steering.LimitsEnabled = true
                steering.LowerAngle = -55
                steering.UpperAngle = 55
            else
                weld(carrier, hub)
            end
            local wheel = part(model, "Wheel", Vector3.new(1.1, 2.6, 2.6), wheelFrame, Color3.fromRGB(22, 23, 25), false)
            wheel.Shape = Enum.PartType.Cylinder
            wheel.CustomPhysicalProperties = PhysicalProperties.new(1.3, 1.5, 0.03, 100, 100)
            wheel:SetAttribute("Side", x)
            wheel:SetAttribute("Rear", z > 0)
            wheel:SetAttribute("Attached", true)
            local axle = join(wheel, "HingeConstraint", attachment(hub, Vector3.zero, right, up), attachment(wheel, Vector3.zero, right, up))
            axle.Name = "Axle"
            axle.ActuatorType = Enum.ActuatorType.Motor
            axle.MotorMaxTorque = 0
            axle.MotorMaxAcceleration = 110
            noCollision(root, wheel)
            for _, item in ipairs(panels) do
                noCollision(item.part, wheel)
            end
            wheels[#wheels + 1] = {part = wheel, carrier = carrier, hub = hub, slide = slide, spring = spring, axle = axle, steering = steering, rear = z > 0, attached = true}
        end
    end
    model.Parent = parent
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CollisionGroup = "PrototypeVan"
            object:SetNetworkOwner(nil)
        end
    end
    return {model = model, root = root, seat = seat, wheels = wheels, panels = panels}
end

return Build
