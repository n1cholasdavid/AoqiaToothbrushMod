-- -------------------------------------------------------------------------- --
--                                ModData stuff                               --
-- -------------------------------------------------------------------------- --

local AQConstants = require("AQConstants")

-- ------------------------------ Module Start ------------------------------ --

local AQModData = {}

-- Only used for type-checking purposes.
---@class AQModDataStruct
---@field daysWithoutBrushingTeeth number | nil
---@field timesBrushedTeethToday number | nil
AQModData.AQModDataStructDummy = {
    _modId = AQConstants.MOD_ID,
    daysWithoutBrushingTeeth = 0,
    timesBrushedTeethToday = 0,
}

return AQModData
