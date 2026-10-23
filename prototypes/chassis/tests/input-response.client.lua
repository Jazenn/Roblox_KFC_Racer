-- Run through MCP in a local Play Client, then send W+D for 300 ms,
-- release both, and send S for 250 ms. Read ChassisResponseProbe.Result.
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
assert(not workspace:FindFirstChild("ChassisResponseProbe"), "Restart Play before repeating this probe")
local probe = Instance.new("Folder")
probe.Name = "ChassisResponseProbe"
probe.Parent = workspace
local pressedAt = {}
local latency = {}
local began = UserInputService.InputBegan:Connect(function(input)
    local key = input.KeyCode.Name
    if key == "W" or key == "D" or key == "S" then
        pressedAt[key] = os.clock()
    end
end)
task.spawn(function()
    local start = os.clock()
    while os.clock() - start < 2.5 do
        local world = workspace:FindFirstChild("ChassisPrototypeWorld")
        local van = world and world:FindFirstChild("PlayerVan")
        local axle = van and van:FindFirstChild("Axle", true)
        local servo = van and van:FindFirstChild("SteeringServo", true)
        local active = {
            W = axle and math.abs(axle.AngularVelocity) > 1,
            D = servo and math.abs(servo.TargetAngle) > 1,
            S = axle and axle.MotorMaxTorque >= 24000,
        }
        for _, key in ipairs({"W", "D", "S"}) do
            if pressedAt[key] and not latency[key] and active[key] then
                latency[key] = os.clock() - pressedAt[key]
            end
        end
        RunService.RenderStepped:Wait()
    end
    began:Disconnect()
    local passed = true
    for _, key in ipairs({"W", "D", "S"}) do
        if not latency[key] or latency[key] > 0.1 then
            passed = false
        end
    end
    probe:SetAttribute("Result", HttpService:JSONEncode({passed = passed, seconds = latency}))
    assert(passed, "Keyboard-to-motor/steering/brake response exceeded 100 ms or no command was observed")
end)
return "Input probe armed; send the specified keyboard sequence now"
