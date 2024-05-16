-- -------------------------------------------------------------------------- --
--                    Defines and adds moodles to the game.                   --
-- -------------------------------------------------------------------------- --

require("MF_ISMoodle")
local MoodleFactory = MF

local AQLog = require("AoqiaToothbrushMod/AQLog")

-- ------------------------------ Module Start ------------------------------ --

local AQMoodles = {}

---@param sandboxVars AQSandboxVarsStruct
---@param player IsoPlayer
---@return number newMax
--- Calculates the new BrushTeethMaxValue based on the player's current traits.
function AQMoodles.calcMaxValue(sandboxVars, player)
    local max = sandboxVars.BrushTeethMaxValue

    if player:HasTrait("GoldenBrusher") then
        max = max / 2
    elseif player:HasTrait("FoulBrusher") then
        max = max * 2
    end

    return max
end

function AQMoodles.init()
    AQLog.debug("Creating moodles...")

    MoodleFactory.createMoodle("DirtyTeeth")
end

return AQMoodles
