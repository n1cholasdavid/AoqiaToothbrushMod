-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

local math                     = math

local pairs                    = pairs

local Events                   = Events
local ModData                  = ModData
local SandboxVars              = SandboxVars

local getPlayer                = getPlayer

local AQWorldObjectContextMenu = require("AQUI/AQWorldObjectContextMenu")
local AQConstants              = require("AQConstants")
local AQTranslations           = require("AQTranslations")
local AQTweaks                 = require("AQTweaks")
local AQUtils                  = require("AQUtils")

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
                if     data.daysWithoutBrushingTeeth == nil
                or     data.timesBrushedTeethToday == nil
                or     data._modVersion == nil then
                    ModData.add(AQConstants.MOD_ID, AQModDataStructDummy)
                elseif data._modVersion ~= AQConstants.MOD_VERSION then
                    AQUtils.logdebug("Mod data version mismatch. Expected version=" ..
                        AQConstants.MOD_VERSION ..
                        " but got version=" ..
                        data._modVersion ..
                        "\nMerging old mod data with dummy mod data.")

                    local dummy = AQModDataStructDummy
                    -- NOTE: This is only a shallow copy!!! Any nested tables will NOT be merged.
                    for k, v in pairs(data) do
                        if k ~= "_modVersion" then
                            dummy[k] = v
                        end
                    end
                    ModData.add(AQConstants.MOD_ID, dummy)
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

        local doDailyEffect = SandboxVars[AQConstants.MOD_ID].DoDailyEffect
        if data.daysWithoutBrushingTeeth > 0 and doDailyEffect then
            local player = getPlayer()
            local stats = player:getStats()
            local bd = player:getBodyDamage()

            ---@type number
            local gracePeriod = SandboxVars[AQConstants.MOD_ID].DailyEffectGracePeriod
            ---@type number
            local unhappyRate = SandboxVars[AQConstants.MOD_ID].DailyEffectExponent
            ---@type number
            local stressRate = SandboxVars[AQConstants.MOD_ID].DailyEffectAlternateExponent
            ---@type number
            local unhappyMax = SandboxVars[AQConstants.MOD_ID].DailyEffectMaxValue
            ---@type number
            local stressMax = SandboxVars[AQConstants.MOD_ID].DailyEffectAlternateMaxValue

            -- NOTE: For visualisation purposes, see https://www.desmos.com/calculator/g4kaux58kl
            local unhappyFormula = AQUtils.clamp(
                math.exp(unhappyRate * (data.daysWithoutBrushingTeeth - gracePeriod)),
                0,
                unhappyMax)
            local stressFormula = AQUtils.clamp(
                math.exp(stressRate * (data.daysWithoutBrushingTeeth - gracePeriod)),
                0,
                stressMax)

            ---@type number
            local effectType = SandboxVars[AQConstants.MOD_ID].DailyEffectType
            if effectType == 1 then
                bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappyFormula)
            elseif effectType == 2 then
                bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappyFormula)
                stats:setStress(stats:getStress() + stressFormula)
            elseif effectType == 3 then
                stats:setStress(stats:getStress() + stressFormula)
            else
                AQUtils.logerror("Invalid DailyEffectType enum value")
            end
        end
    end)
end

return AQEvents
