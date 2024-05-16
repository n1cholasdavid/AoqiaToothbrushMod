-- -------------------------------------------------------------------------- --
--                           A small logging module                           --
-- -------------------------------------------------------------------------- --

local AQConstants = require("AoqiaToothbrushMod/AQConstants")

-- ------------------------------ Module Start ------------------------------ --

local AQLog = {}

AQLog.prefix = ("[" .. AQConstants.MOD_ID)

---@param msg string
function AQLog.debug(msg)
    if AQConstants.IS_DEBUG == false then return end
    print(AQLog.prefix .. "] [DEBUG] " .. msg)
end

---@param msg string
function AQLog.debugServer(msg)
    if AQConstants.IS_DEBUG == false then return end
    print(AQLog.prefix .. "/Server" .. "] [DEBUG] " .. msg)
end

---@param msg string
function AQLog.info(msg)
    print(AQLog.prefix .. "] [INFO] " .. msg)
end

---@param msg string
function AQLog.infoServer(msg)
    print(AQLog.prefix .. "/Server" .. "] [INFO] " .. msg)
end

---@param msg string
function AQLog.warn(msg)
    print(AQLog.prefix .. "] [WARN] ### " .. msg .. " ###")
end

---@param msg string
function AQLog.warnServer(msg)
    print(AQLog.prefix .. "/Server" .. "] [WARN] ### " .. msg .. " ###")
end

---@param msg string
function AQLog.error(msg)
    local str = ("\n" .. AQLog.prefix .. "] [ERROR] ###### " .. msg .. " ######\n")
    print(str)
    error(str, 1)
end

---@param msg string
function AQLog.errorServer(msg)
    local str = ("\n" .. AQLog.prefix .. "/Server" .. "] [ERROR] ###### " .. msg .. " ######\n")
    print(str)
    error(str, 1)
end

return AQLog
