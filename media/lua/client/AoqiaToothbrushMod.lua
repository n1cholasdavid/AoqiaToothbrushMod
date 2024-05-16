-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local getActivatedMods = getActivatedMods

local AQEvents = require("AoqiaToothbrushMod/AQEvents")
local AQLog = require("AoqiaToothbrushMod/AQLog")

-- ------------------------------- Entrypoint ------------------------------- --

local activated_mods = getActivatedMods()
if not activated_mods:contains("ItemTweakerAPI") or not activated_mods:contains("MoodleFramework") then
    AQLog.error("Failed to find ItemTweakerAPI or MoodleFramework.")
    return
end

AQEvents.register()

AQLog.debug("Lua init done!")
