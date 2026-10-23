local fs = require('@lune/fs')
local roblox = require('@lune/roblox')
local roots = roblox.deserializeModel(fs.readFile('prototypes/visual/assets/KombiSource.rbxm'))
assert(#roots == 1 and roots[1].ClassName == 'Model', 'Expected one geometry model')
local parts = 0
for _, object in ipairs(roots[1]:GetDescendants()) do
    assert(not object:IsA('LuaSourceContainer'), 'Imported executable code')
    assert(not object:IsA('JointInstance') and not object:IsA('Constraint'), 'Imported physics rig')
    assert(not object:IsA('Seat') and not object:IsA('VehicleSeat'), 'Imported seat')
    if object:IsA('BasePart') then
        parts += 1
        assert(object.Anchored and not object.CanCollide and not object.CanTouch, 'Active geometry')
    else
        assert(object:IsA('DataModelMesh'), 'Unexpected imported class: ' .. object.ClassName)
    end
end
assert(parts > 100, 'Model geometry missing')
print('PASS: serialized source contains ' .. parts .. ' static parts, mesh data only, no executable code or chassis')