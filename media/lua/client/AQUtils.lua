-- -------------------------------------------------------------------------- --
--                   Has utility functions used by the mod.                   --
-- -------------------------------------------------------------------------- --

local AQConstants = require("AQConstants")

-- ------------------------------ Module Start ------------------------------ --

local AQUtils = {}

---@param msg string
function AQUtils.logdebug(msg)
    if AQConstants.IS_DEBUG then
        print("[" .. AQConstants.MOD_ID .. "] " .. msg)
    end
end

---@param msg string
function AQUtils.logerror(msg)
    error("[" .. AQConstants.MOD_ID .. "] " .. msg, 1)
end

---@param num number
---@param min number
---@param max number
function AQUtils.clamp(num, min, max)
    if num < min then
        num = min
    elseif num > max then
        num = max
    end

    return num
end

return AQUtils
