-- -------------------------------------------------------------------------- --
--                   Stores constants to be used everywhere.                  --
-- -------------------------------------------------------------------------- --

-- ------------------------------ Module Start ------------------------------ --

local AQConstants = {}

AQConstants.IS_DEBUG = getDebug()
AQConstants.IS_LAST_STAND = getCore():getGameMode() == "LastStand"

AQConstants.MOD_ID = "AoqiaToothbrushMod"
AQConstants.MOD_VERSION = "1.1.0"

return AQConstants
