-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local getActivatedMods = getActivatedMods

local AQEvents = require("AQEvents")
local AQUtils = require("AQUtils")

-- ------------------------------- Entrypoint ------------------------------- --

local activated_mods = getActivatedMods()
if not activated_mods:contains("ItemTweakerAPI") or not activated_mods:contains("MoodleFramework") then
    AQUtils.logerror("Failed to find ItemTweakerAPI or MoodleFramework.")
    return
end

AQEvents.register()

AQUtils.logdebug("Up and running!")
