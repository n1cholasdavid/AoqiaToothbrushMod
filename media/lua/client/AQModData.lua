-- -------------------------------------------------------------------------- --
--                                ModData stuff                               --
-- -------------------------------------------------------------------------- --

-- ------------------------------ Module Start ------------------------------ --

local AQModData = {}

-- Only used for type-checking purposes.
---@class AQModDataStruct
---@field daysWithoutBrushingTeeth number | nil
---@field timesBrushedTeethToday number | nil
AQModData.AQModDataStructDummy = {
    daysWithoutBrushingTeeth = 0,
    timesBrushedTeethToday = 0,
}

return AQModData
