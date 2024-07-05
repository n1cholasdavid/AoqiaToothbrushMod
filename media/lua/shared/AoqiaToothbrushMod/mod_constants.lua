-- -------------------------------------------------------------------------- --
--                   Stores constants to be used everywhere.                  --
-- -------------------------------------------------------------------------- --

local logger = require("AoqiaZomboidUtils/logger")

-- ------------------------------ Module Start ------------------------------ --

local mod_constants = {}

mod_constants.MOD_ID = "AoqiaToothbrushMod"
mod_constants.MOD_VERSION = "1.2.1"

mod_constants.LOGGER = logger:new(mod_constants.MOD_ID)

return mod_constants
