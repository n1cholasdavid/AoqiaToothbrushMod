-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local distributions = require("AoqiaToothbrushMod/distributions")
local mod_constants = require("AoqiaToothbrushMod/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------- Entrypoint ------------------------------- --

distributions.register()

logger.debug_server("Lua init done!")
