-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local AQLog = require("AoqiaToothbrushMod/AQLog")
local AQProceduralDistributions = require("AoqiaToothbrushMod/AQProceduralDistributions")

-- ------------------------------- Entrypoint ------------------------------- --

AQProceduralDistributions.init()

AQLog.debugServer("Lua init done!")
