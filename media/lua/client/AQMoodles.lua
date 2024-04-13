-- -------------------------------------------------------------------------- --
--                    Defines and adds moodles to the game.                   --
-- -------------------------------------------------------------------------- --

require("MF_ISMoodle")
local MoodleFactory = MF

-- ------------------------------ Module Start ------------------------------ --

local AQMoodles = {}

function AQMoodles.add()
    MoodleFactory.createMoodle("DirtyTeeth")
end

return AQMoodles
