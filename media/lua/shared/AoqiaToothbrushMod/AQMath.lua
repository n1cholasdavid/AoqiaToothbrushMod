-- -------------------------------------------------------------------------- --
--           A utility module for math stuff not in lua math module           --
-- -------------------------------------------------------------------------- --

-- ------------------------------ Module Start ------------------------------ --

local AQMath = {}

---@param value number
---@param min number
---@param max number
-- This function is basically just `min(max(value, min), max)`.
function AQMath.clamp(value, min, max)
    local result = value

    if value < min then
        result = min
    elseif value > max then
        result = max
    end

    return result
end

return AQMath
