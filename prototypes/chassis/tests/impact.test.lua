local Model = require("../src/DriveModel")
local history = {}
local function sample(now, speed, contact, damaged)
    return Model.impactStep(history, now, speed, contact, damaged or false)
end
assert(sample(0, 78, false) == "none", "initial speed is not an impact")
assert(sample(0.05, 60, true) == "none", "initial small loss")
assert(sample(0.1, 42, true) == "damage", "multi-update collision must detach a part")
assert(sample(0.15, 20, true, true) == "none", "damaged van survives a hit short of a full crash")
assert(sample(0.2, 5, true, true) == "wreck", "same collision can progress to a full-on crash")
history = {}
sample(0, 78, false)
assert(sample(0.1, 10, false) == "none", "speed loss without body contact is not damage")
assert(sample(0.5, 10, true) == "none", "late contact must not reuse an expired speed peak")
history = {}
sample(0, 45, false)
assert(sample(0.1, 10, true, true) == "none", "already damaged moderate impact does not shed more wheels")
history = {}
sample(0, 20, false)
assert(sample(0.1, 0, true) == "none", "slow tumble contact does not break parts")
assert(Model.recoveryReason(1.5, 5) == "overturned", "overturned van requests recovery separately")
assert(Model.recoveryReason(0, -26) == "fallen", "off-pad fall requests recovery")
assert(Model.recoveryReason(1, 5) == nil, "brief roll does not request recovery")
print("PASS: 12 collision-window and non-destructive recovery assertions")
return true
