-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local AQEvents = require("AQEvents")
local AQTranslations = require("ISUI/AQTranslations")
local AQTweaks = require("AQTweaks")
local AQUtils = require("AQUtils")

-- ------------------------------- Entrypoint ------------------------------- --

AQTranslations:updateCache()
AQEvents:init()
AQTweaks:init()

AQUtils.logdebug("Up and running!")
