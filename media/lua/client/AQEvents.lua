-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

local Events = Events

local AQGlobals = require("AQGlobals")
local AQWorldObjectContextMenu = require("ISUI/AQWorldObjectContextMenu")

-- ------------------------------ Module Start ------------------------------ --

local AQEvents = {}

function AQEvents:init()
    Events.OnFillWorldObjectContextMenu.Add(AQWorldObjectContextMenu.createMenu)
    Events.EveryDays.Add(function ()
        AQGlobals.daysWithoutBrushingTeeth = AQGlobals.daysWithoutBrushingTeeth + 1
        -- TODO: Somehow get the character here (maybe pass playerIndex as a global?) and then increment the unhappyness level to something reasonable. 
    end)
end

return AQEvents
