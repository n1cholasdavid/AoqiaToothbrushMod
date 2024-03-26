-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local AQEvents = require("AQEvents")
local AQUtils = require("AQUtils")

-- ------------------------------- Entrypoint ------------------------------- --

AQEvents.register()

AQUtils.logdebug("Up and running!")
