-- -------------------------------------------------------------------------- --
--                   Has utility functions used by the mod.                   --
-- -------------------------------------------------------------------------- --

local AQConstants = require("AQConstants")

-- ------------------------------ Module Start ------------------------------ --

local AQUtils = {}

---@param msg string
function AQUtils.logdebug(msg)
    if AQConstants.IS_DEBUG then
        print("[" .. AQConstants.MOD_ID .. "]: " .. msg)
    end
end

---@param msg string
function AQUtils.logerror(msg)
    error("[" .. AQConstants.MOD_ID .. "]: " .. msg, 1)
end

---@param value number
---@param min number
---@param max number
-- This function is basically just `min(max(value, min), max)`.
function AQUtils.clamp(value, min, max)
    local result = value

    if value < min then
        result = min
    elseif value > max then
        result = max
    end

    return result
end

return AQUtils
