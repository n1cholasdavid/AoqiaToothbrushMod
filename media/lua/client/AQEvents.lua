-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

local Events                   = Events
local ModData                  = ModData

local getPlayer                = getPlayer

local AQWorldObjectContextMenu = require("AQUI/AQWorldObjectContextMenu")
local AQConstants              = require("AQConstants")
local AQModData                = require("AQModData")
local AQTranslations           = require("AQTranslations")
local AQTweaks                 = require("AQTweaks")

-- ------------------------------ Module Start ------------------------------ --

local AQEvents                 = {}

-- Only used for type-checking purposes in ModData.
---@class AQModDataStruct
---@field _modVersion string | nil
---@field daysWithoutBrushingTeeth number | nil
---@field timesBrushedTeethToday number | nil
local AQModDataStructDummy     = {
    _modVersion = AQConstants.MOD_VERSION,
    daysWithoutBrushingTeeth = 0,
    timesBrushedTeethToday = 0,
}

function AQEvents.register()
    Events.OnGameBoot.Add(function ()
        AQTranslations.update()
        AQTweaks.apply()
    end)

    Events.OnInitGlobalModData.Add(function (newGame)
        -- I am doing this seperately because I think creating and returning a table that...
        -- also internally checks if the table exists before creating it will cost some performance.
        if newGame then
            ModData.add(AQConstants.MOD_ID, AQModDataStructDummy)
        else
            -- If it doesn't exist then create new, otherwise load it and check nil. If nil then create new.
            if not ModData.exists(AQConstants.MOD_ID) then
                ModData.add(AQConstants.MOD_ID, AQModDataStructDummy)
            else
                ---@type AQModDataStruct
                local data = ModData.get(AQConstants.MOD_ID)
                if data.daysWithoutBrushingTeeth == nil
                or data.timesBrushedTeethToday == nil
                or data._modVersion == nil then
                    ModData.add(AQConstants.MOD_ID, AQModDataStructDummy)
                end
            end
        end
    end)

    Events.OnPlayerDeath.Add(function (deadPlayer)
        local clientPlayer = getPlayer()
        if deadPlayer == clientPlayer then
            ModData.add(AQConstants.MOD_ID, AQModDataStructDummy)
        end
    end)

    Events.OnFillWorldObjectContextMenu.Add(AQWorldObjectContextMenu.createMenu)

    Events.EveryDays.Add(function ()
        ---@type AQModDataStruct
        local data = ModData.get(AQConstants.MOD_ID)
        if data.timesBrushedTeethToday == 0 then
            data.daysWithoutBrushingTeeth = data.daysWithoutBrushingTeeth + 1
        else
            data.daysWithoutBrushingTeeth = 0
            data.timesBrushedTeethToday = 0
        end

        if data.daysWithoutBrushingTeeth > 0 then
            local bd = getPlayer():getBodyDamage()
            bd:setUnhappynessLevel(bd:getUnhappynessLevel() + 5)
        end
    end)
end

return AQEvents
