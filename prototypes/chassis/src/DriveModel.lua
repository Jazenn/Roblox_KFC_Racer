-- Throwaway chassis experiment. Pure rules shared by Studio and the CLI tests.
local DriveModel = {}

function DriveModel.finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function DriveModel.accept(now, previous, isDriver, throttle, steering, handbrake)
    if not isDriver or not DriveModel.finite(now) or not DriveModel.finite(previous) then
        return false
    end
    if now - previous < 1 / 30 then
        return false
    end
    if not DriveModel.finite(throttle) or not DriveModel.finite(steering) then
        return false
    end
    return math.abs(throttle) <= 1 and math.abs(steering) <= 1 and type(handbrake) == "boolean"
end

function DriveModel.drive(speed, throttle, steering, handbrake)
    local target = throttle * 78
    local torque = 8000
    if throttle < 0 then
        target = -26
        if speed > 4 then
            target = 0
            torque = 24000
        end
    elseif throttle == 0 then
        target = 0
        torque = 100
    end
    local rearTorque = torque
    local rearTarget = target
    if handbrake then
        rearTorque = 36000
        rearTarget = 0
    end
    local angle = steering * 36 / (1 + math.abs(speed) / 500)
    return target, torque, rearTarget, rearTorque, angle
end

function DriveModel.axes(forward, reverse, left, right)
    return (forward and 1 or 0) - (reverse and 1 or 0),
        (right and 1 or 0) - (left and 1 or 0)
end

function DriveModel.wheel(angle, side, rear)
    local curvature = math.tan(math.rad(angle)) / 7.4
    local lateral = 1 - side * curvature
    if rear then
        return 0, lateral
    end
    local longitudinal = 7.4 * curvature
    return math.deg(math.atan(longitudinal / lateral)),
        math.sqrt(lateral * lateral + longitudinal * longitudinal)
end

function DriveModel.rollLoad(speed, steering, grounded)
    if not grounded or math.abs(speed) <= 65 or math.abs(steering) <= 0.65 then
        return 0
    end
    local speedRisk = math.min(1, (math.abs(speed) - 65) / 13)
    local steerRisk = (math.abs(steering) - 0.65) / 0.35
    local sign = steering / math.abs(steering)
    return sign * speedRisk * speedRisk * steerRisk * steerRisk
end

function DriveModel.rollStep(previous, speed, steering, grounded, dt)
    local step = math.max(0, math.min(dt, 0.1))
    local target = DriveModel.rollLoad(speed, steering, grounded)
    if target == 0 then
        local remaining = math.max(0, math.abs(previous) - step * 2.5)
        return (previous < 0 and -remaining or remaining), 0
    end
    if previous * target < 0 then
        previous = 0
    end
    local sign = target / math.abs(target)
    local exposure = math.min(1, math.abs(previous) + step * math.abs(target) / 1.4)
    local ramp = math.max(0, (exposure - 0.25) / 0.75)
    return sign * exposure, target * ramp * ramp
end

function DriveModel.impact(previousSpeed, speed, alreadyDamaged)
    local loss = previousSpeed - speed
    if previousSpeed >= 70 and loss >= 60 then
        return "wreck"
    end
    if not alreadyDamaged and previousSpeed >= 45 and loss >= 35 then
        return "damage"
    end
    return "none"
end

function DriveModel.canRecover(now, wreckTime)
    return now - wreckTime >= 3
end

function DriveModel.impactStep(history, now, speed, contact, damaged)
    local peak = speed
    for index = #history, 1, -1 do
        local sample = history[index]
        if now - sample.time > 0.3 then
            table.remove(history, index)
        else
            peak = math.max(peak, sample.speed)
        end
    end
    history[#history + 1] = {time = now, speed = speed}
    if not contact then
        return "none"
    end
    return DriveModel.impact(peak, speed, damaged)
end

function DriveModel.recoveryReason(upsideDownTime, height)
    if height < -25 then
        return "fallen"
    end
    if upsideDownTime > 1.4 then
        return "overturned"
    end
    return nil
end

return DriveModel
