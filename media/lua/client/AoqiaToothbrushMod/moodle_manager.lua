-- -------------------------------------------------------------------------- --
--                    Defines and adds moodles to the game.                   --
-- -------------------------------------------------------------------------- --

require("MF_ISMoodle")
local MoodleFactory = MF

local mod_constants = require("AoqiaToothbrushMod/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local moodle_manager = {}

---@param sandboxVars sandboxvars_struct
---@param player IsoPlayer
---@return number newMax
--- Calculates the new BrushTeethMaxValue based on the player's current traits.
function moodle_manager.calc_max(sandboxVars, player)
    local max = sandboxVars.BrushTeethMaxValue

    if player:HasTrait("GoldenBrusher") then
        max = max / 2
    elseif player:HasTrait("FoulBrusher") then
        max = max * 2
    end

    return max
end

function moodle_manager.init()
    logger.debug("Creating moodles...")

    MoodleFactory.createMoodle("DirtyTeeth")
end

return moodle_manager
