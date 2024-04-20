-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

-- STD Lua Global Tables/Variables
local math        = math

-- STD Lua Global Functions
local pairs       = pairs

-- Vanilla Global Tables/Variables
local Events      = Events
local SandboxVars = SandboxVars

-- Vanilla Global Functions
local getPlayer   = getPlayer

-- Dependency Global Tables/Variables
require("MF_ISMoodle")
local MoodleFactory              = MF

-- My Mod Modules
local AQWorldObjectContextMenu   = require("AoqiaToothbrushMod/AQUI/AQWorldObjectContextMenu")
local AQConstants                = require("AoqiaToothbrushMod/AQConstants")
local AQMoodles                  = require("AoqiaToothbrushMod/AQMoodles")
local AQTraits                   = require("AoqiaToothbrushMod/AQTraits")
local AQTranslations             = require("AoqiaToothbrushMod/AQTranslations")
local AQTweaks                   = require("AoqiaToothbrushMod/AQTweaks")
local AQUtils                    = require("AoqiaToothbrushMod/AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQEvents                   = {}

-- NOTE: Probably move these dummy structs to a more suitable location? Although I can't figure out where.

---@class AQPlayerModDataStruct
---@field _modVersion string Tracks what version of the mod belongs to the mod data.
---@field daysBrushedCount number Tracks the number of days CONSECUTIVELY the player has brushed their teeth at least once.
---@field daysBrushedToMax number Tracks how many times player CONSECUTIVELY brushed teeth >= sandbox Max Value for n days.
---@field todayBrushCount number Tracks how many times player brushed teeth today.
---@field totalBrushCount number Tracks how many times player brushed teeth total.
---@field daysNotBrushed number Tracks how many CONSECUTIVE times player didn't brush teeth total.
---@field brushTeethNewMaxValue number Tracks the sandbox option "Brush Teeth Max Value" based on if the player has one of the traits.
---@field timeLastBrushTenMins number Tracks how much time (in 10 minute intervals) since the last brush.
local AQPlayerModDataStructDummy = {
    _modVersion = AQConstants.MOD_VERSION,
    daysBrushedCount = 0,
    daysBrushedToMax = 0,
    todayBrushCount = 0,
    totalBrushCount = 0,
    daysNotBrushed = 0,
    brushTeethNewMaxValue = 0,
    timeLastBrushTenMins = 0,
}
---@class AQSandboxVarsStruct
---@field DoTransferItemsOnUse boolean
---@field DoDailyEffect boolean
---@field DailyEffectType number
---@field DailyEffectExponent number
---@field DailyEffectAlternateExponent number
---@field DailyEffectMaxValue number
---@field DailyEffectAlternateMaxValue number
---@field DailyEffectGracePeriod number
---@field DoBrushTeethEffect boolean
---@field BrushTeethEffectType number
---@field BrushTeethEffectAmount number
---@field BrushTeethEffectAlternateAmount number
---@field BrushTeethTime number
---@field BrushTeethMaxValue number
---@field BrushTeethRequiredWater number
---@field BrushTeethRequiredToothpaste number
---@field GoodTraitCount number
---@field BadTraitCount number
local AQSandboxVarsStructDummy   = {
    DoTransferItemsOnUse = true,
    -- Daily Effect
    DoDailyEffect = true,
    DailyEffectType = 1,
    DailyEffectExponent = 0.12,
    DailyEffectAlternateExponent = 0.12,
    DailyEffectMaxValue = 25,
    DailyEffectAlternateMaxValue = 25,
    DailyEffectGracePeriod = 2,
    -- Brush Teeth Effect
    DoBrushTeethEffect = true,
    BrushTeethEffectType = 1,
    BrushTeethEffectAmount = 10,
    BrushTeethEffectAlternateAmount = 10,
    -- Brush Teeth Vars
    BrushTeethTime = 600,
    BrushTeethMaxValue = 2,
    BrushTeethRequiredWater = 1,
    BrushTeethRequiredToothpaste = 1,
    -- Trait Vars
    GoodTraitCount = 10,
    BadTraitCount = 7,
}

function AQEvents.OnGameBoot()
    -- NOTE: The order of these calls matter!
    AQTranslations.update()
    AQTraits.add()
    AQMoodles.add()
    AQTweaks.apply()
end

---@param newGame boolean
function AQEvents.OnInitGlobalModData(newGame)
    -- Remove the accidental addition to the global mod data that I did from 1.0.0 to 1.0.1.
    -- If you're curious, ask me. If you don't care, just know this is fixed.
    -- Clean up your previous mistakes instead of letting the result rot in people's world saves!!!!!
    if ModData.exists(AQConstants.MOD_ID) then
        AQUtils.logdebug("Found old global mod data. Removing...")
        ModData.remove(AQConstants.MOD_ID)
    end
end

---@param playerNum number The player number of the newly-spawned character.
---@param player IsoPlayer The new player object.
function AQEvents.OnCreatePlayer(playerNum, player)
    -- Maybe do modData[AQConstants.MOD_ID] = AQPlayerModDataStructDummy?
    -- local modData = player:getModData()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    ---@type AQSandboxVarsStruct
    local sandboxVars = SandboxVars[AQConstants.MOD_ID]

    -- Has user created a new character?
    -- Has the user enabled the mod on an existing character?
    local newChar = (data == nil or data._modVersion == nil)
    if newChar then
        player:getModData()[AQConstants.MOD_ID] = AQPlayerModDataStructDummy
        return
    end

    -- Outdated mod data check and merge
    -- This keeps the old data values and merges them with the new table
    if data._modVersion ~= AQConstants.MOD_VERSION then
        AQUtils.logdebug("Mod data version mismatch." ..
            " Expected version=" .. AQConstants.MOD_VERSION ..
            " but got version=" .. data._modVersion ..
            "; Merging old mod data with dummy mod data.")

        local dummy = AQPlayerModDataStructDummy
        for k, v in pairs(dummy) do
            if k ~= "modVersion" and data[k] ~= nil then
                dummy[k] = data[k]
            end
        end

        player:getModData()[AQConstants.MOD_ID] = dummy
        return
    end

    -- Lazy nil data check
    -- This compares with the dummy struct for new data keys not in the table
    for k, v in pairs(AQPlayerModDataStructDummy) do
        if data[k] == nil then
            AQUtils.logdebug("Found nil value in mod data. Adding defaults...")
            data[k] = v
        end
    end

    if data.brushTeethNewMaxValue == 0 then
        -- Do some mod data stuff for cases where
        local newMax = AQMoodles.calcMaxValue(sandboxVars, player)
        data.brushTeethNewMaxValue = newMax
    end
end

---@param deadPlayer IsoPlayer The player that died to trigger this event.
function AQEvents.OnPlayerDeath(deadPlayer)
    local player = getPlayer()

    -- Reset the mod data of the player if they died.
    if deadPlayer == player then
        player:getModData()[AQConstants.MOD_ID] = AQPlayerModDataStructDummy
    end
end

function AQEvents.EveryDays()
    local player = getPlayer()
    local traits = player:getTraits()
    local stats = player:getStats()
    local bd = player:getBodyDamage()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    -- Daily mod data update logic
    if data.todayBrushCount == 0 then
        data.daysNotBrushed = data.daysNotBrushed + 1
        data.daysBrushedToMax = 0
        data.daysBrushedCount = 0
    else
        data.daysBrushedCount = data.daysBrushedCount + 1
        data.daysNotBrushed = 0
    end

    -- Trait stuff is below.
    -- Trait logic is calculated daily because it closely relies on the amount of days not brushed.

    ---@type AQSandboxVarsStruct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[AQConstants.MOD_ID]
    if not sandboxVars or sandboxVars.DoTransferItemsOnUse == nil then
        AQUtils.logerror("No sandbox variables found. " ..
            "This should never happen so please make an issue on github or comment on the mod workshop page.")
        return
    end

    -- Assign trait depending on mod data
    if data.daysNotBrushed >= sandboxVars.BadTraitCount and player:HasTrait("FoulBrusher") == false then
        if player:HasTrait("GoldenBrusher") then
            traits:remove("GoldenBrusher")
        end

        traits:add("FoulBrusher")
    elseif data.daysBrushedToMax >= sandboxVars.GoodTraitCount and player:HasTrait("GoldenBrusher") == false then
        if player:HasTrait("FoulBrusher") then
            traits:remove("FoulBrusher")
        end

        traits:add("GoldenBrusher")
    end

    -- Remove GoldenBrusher if we have haven't brushed
    -- Remove FoulBrusher if we have brushed
    if data.daysBrushedToMax == 0 and player:HasTrait("GoldenBrusher") then
        traits:remove("GoldenBrusher")
    elseif data.daysNotBrushed == 0 and player:HasTrait("FoulBrusher") then
        traits:remove("FoulBrusher")
    end

    -- Calc new brush count influenced by the trait
    local newMax = AQMoodles.calcMaxValue(sandboxVars, player)
    data.brushTeethNewMaxValue = newMax

    -- Reset moodle
    local moodle = MoodleFactory.getMoodle("DirtyTeeth", player:getPlayerNum())
    moodle:setValue(0.5)

    -- Using trait logic to update mod data
    if data.todayBrushCount ~= 0 then
        if data.todayBrushCount >= newMax then
            data.daysBrushedToMax = data.daysBrushedToMax + 1
        end

        data.todayBrushCount = 0
    end

    -- Is the daily effect active?
    local doDailyEffect = sandboxVars.DoDailyEffect
    if data.daysNotBrushed <= 0 or doDailyEffect == false then
        return
    end

    local gracePeriod = sandboxVars.DailyEffectGracePeriod
    local unhappyRate = sandboxVars.DailyEffectExponent
    local stressRate = sandboxVars.DailyEffectAlternateExponent
    local unhappyMax = sandboxVars.DailyEffectMaxValue
    local stressMax = sandboxVars.DailyEffectAlternateMaxValue

    -- NOTE: For visualisation purposes, see https://www.desmos.com/calculator/awdp9rmxs8
    local unhappyFormula = AQUtils.clamp(math.exp(
            unhappyRate * (data.daysNotBrushed - gracePeriod) /
            (AQUtils.tonumber(data.daysNotBrushed >= (newMax / 2)) + 1)),
        0,
        unhappyMax)
    local stressFormula = AQUtils.clamp(math.exp(
            stressRate * (data.daysNotBrushed - gracePeriod) /
            (AQUtils.tonumber(data.daysNotBrushed >= (newMax / 2)) + 1)),
        0,
        stressMax)

    -- Set the daily effect using the formula above.
    local effectType = sandboxVars.DailyEffectType
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

function AQEvents.EveryTenMinutes()
    local player = getPlayer()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    data.timeLastBrushTenMins = data.timeLastBrushTenMins + 10
end

function AQEvents.register()
    Events.OnGameBoot.Add(AQEvents.OnGameBoot)
    Events.OnInitGlobalModData.Add(AQEvents.OnInitGlobalModData)
    Events.OnCreatePlayer.Add(AQEvents.OnCreatePlayer)
    Events.OnPlayerDeath.Add(AQEvents.OnPlayerDeath)
    Events.OnFillWorldObjectContextMenu.Add(AQWorldObjectContextMenu.createMenu)
    Events.EveryDays.Add(AQEvents.EveryDays)
    Events.EveryTenMinutes.Add(AQEvents.EveryTenMinutes)
end

return AQEvents
