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
local AQWorldObjectContextMenu   = require("AQUI/AQWorldObjectContextMenu")
local AQConstants                = require("AQConstants")
local AQMoodles                  = require("AQMoodles")
local AQTraits                   = require("AQTraits")
local AQTranslations             = require("AQTranslations")
local AQTweaks                   = require("AQTweaks")
local AQUtils                    = require("AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQEvents                   = {}

-- NOTE: Probably move these dummy structs to a more suitable location? Although I can't figure out where.

---@class AQPlayerModDataStruct
---@field _modVersion string | nil Tracks what version of the mod belongs to the mod data.
---@field daysBrushedCount number | nil Tracks the number of days CONSECUTIVELY the player has brushed their teeth at least once.
---@field daysBrushedAboveMax number | nil Tracks how many times player CONSECUTIVELY brushed teeth >= sandbox Max Value for n days.
---@field statTeethDirt number | nil Tracks how dirty the player's teeth are from 50 to 100. 0 is ultra clean, 50 is normal, 100 is ultra dirty.
---@field todayBrushCount number | nil Tracks how many times player brushed teeth today.
---@field totalBrushCount number | nil Tracks how many times player brushed teeth total.
---@field totalDaysNotBrushed number | nil Tracks how many CONSECUTIVE times player didn't brush teeth total.
local AQPlayerModDataStructDummy = {
    _modVersion = AQConstants.MOD_VERSION,
    daysBrushedCount = 0,
    daysBrushedAboveMax = 0,
    statTeethDirt = 50,
    todayBrushCount = 0,
    totalBrushCount = 0,
    totalDaysNotBrushed = 0,
}
---@class AQSandboxVarsStruct
---@field DoTransferItemsOnUse boolean | nil
---@field DoDailyEffect boolean | nil
---@field DailyEffectType number | nil
---@field DailyEffectExponent number | nil
---@field DailyEffectAlternateExponent number | nil
---@field DailyEffectMaxValue number | nil
---@field DailyEffectAlternateMaxValue number | nil
---@field DailyEffectGracePeriod number | nil
---@field DoBrushTeethEffect boolean | nil
---@field BrushTeethEffectType number | nil
---@field BrushTeethEffectAmount number | nil
---@field BrushTeethEffectAlternateAmount number | nil
---@field BrushTeethTime number | nil
---@field BrushTeethMaxValue number | nil
---@field BrushTeethRequiredWater number | nil
---@field BrushTeethRequiredToothpaste number | nil
---@field GoodTraitCount number | nil
---@field BadTraitCount number | nil
local AQSandboxVarsStructDummy   = {
    DoTransferItemsOnUse = true,
    -- Daily Effect
    DoDailyEffect = true,
    DailyEffectType = 0,
    DailyEffectExponent = 0.06,
    DailyEffectAlternateExponent = 0.06,
    DailyEffectMaxValue = 0,
    DailyEffectAlternateMaxValue = 0,
    DailyEffectGracePeriod = 0,
    -- Brush Teeth Effect
    DoBrushTeethEffect = true,
    BrushTeethEffectType = 0,
    BrushTeethEffectAmount = 0,
    BrushTeethEffectAlternateAmount = 0,
    -- Brush Teeth Vars
    BrushTeethTime = 600,
    BrushTeethMaxValue = 0,
    BrushTeethRequiredWater = 1,
    BrushTeethRequiredToothpaste = 1,
    -- Trait Vars
    GoodTraitCount = 0,
    BadTraitCount = 0,
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
        ModData.remove(AQConstants.MOD_ID)
    end
end

---@param playerNum number The player number of the newly-spawned character.
---@param player IsoPlayer The new player object.
function AQEvents.OnCreatePlayer(playerNum, player)
    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    -- Has user created a new character?
    -- Has the user enabled the mod on an existing character?
    local newChar = (data == nil or data._modVersion == nil)
    if newChar then
        data = AQPlayerModDataStructDummy
        return
    end

    -- Lazy nil/invalid data check
    for k, _ in pairs(AQPlayerModDataStructDummy) do
        for _, _ in pairs(data) do
            if data[k] == nil then
                data = AQPlayerModDataStructDummy
                return
            end
        end
    end

    -- Outdated mod data check and merge
    if data._modVersion ~= AQConstants.MOD_VERSION then
        AQUtils.logdebug("Mod data version mismatch." ..
            " Expected version=" .. AQConstants.MOD_VERSION ..
            " but got version=" .. data._modVersion ..
            "; Merging old mod data with dummy mod data.")

        local dummy = AQPlayerModDataStructDummy
        for k, v in pairs(data) do
            if k ~= "_modVersion" then
                dummy[k] = v
            end
        end

        data = dummy
    end
end

---@param deadPlayer IsoPlayer The player that died to trigger this event.
function AQEvents.OnPlayerDeath(deadPlayer)
    local player = getPlayer()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    -- Reset the mod data of the player if they died.
    if deadPlayer == player then
        data = AQPlayerModDataStructDummy
    end
end

function AQEvents.EveryTenMinutes()
    local player = getPlayer()
    local playerNum = player:getPlayerNum()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    -- NOTE: The value reaches 100 from 0 LINEARLY after a week (in minutes).
    local formula = (100 / 10080) * 10
    data.statTeethDirt = AQUtils.clamp(data.statTeethDirt + formula, 0, 100)

    local moodle = MoodleFactory.getMoodle("DirtyTeeth", playerNum)
    moodle:setValue(data.statTeethDirt)
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
        data.totalDaysNotBrushed = data.totalDaysNotBrushed + 1
        data.daysBrushedAboveMax = 0
        data.daysBrushedCount = 0
    else
        data.daysBrushedCount = data.daysBrushedCount + 1
        data.totalDaysNotBrushed = 0
    end

    -- Trait stuff is below.
    -- Trait logic is calculated daily because it closely relies on the amount of days not brushed.

    ---@type AQSandboxVarsStruct
    local sandboxVars = SandboxVars[AQConstants.MOD_ID]
    if not sandboxVars or sandboxVars.DoTransferItemsOnUse == nil then
        AQUtils.logerror("No sandbox variables found. " ..
            "This should never happen so please make an issue on github or comment on the mod workshop page.")
        return
    end

    -- Assign trait depending on mod data
    if data.totalDaysNotBrushed > sandboxVars.BadTraitCount then
        traits:add("FoulBrusher")
    elseif data.daysBrushedCount >= sandboxVars.GoodTraitCount then
        traits:add("GoldenBrusher")
    end

    -- Calc new brush count influenced by the trait
    local newMax = sandboxVars.BrushTeethMaxValue
    if player:HasTrait("GoldenBrusher") then
        newMax = newMax / 2
    elseif player:HasTrait("FoulBrusher") then
        newMax = newMax * 2
    end

    -- Using trait logic to update mod data
    if data.todayBrushCount ~= 0 then
        if data.todayBrushCount >= newMax then
            data.daysBrushedAboveMax = data.daysBrushedAboveMax + 1
        end

        data.todayBrushCount = 0
    end

    -- Is the daily effect active?
    local doDailyEffect = sandboxVars.DoDailyEffect
    if data.totalDaysNotBrushed <= 0 or doDailyEffect == false then
        return
    end

    local gracePeriod = sandboxVars.DailyEffectGracePeriod
    local unhappyRate = sandboxVars.DailyEffectExponent
    local stressRate = sandboxVars.DailyEffectAlternateExponent
    local unhappyMax = sandboxVars.DailyEffectMaxValue
    local stressMax = sandboxVars.DailyEffectAlternateMaxValue

    -- NOTE: For visualisation purposes, see https://www.desmos.com/calculator/awdp9rmxs8
    local unhappyFormula = AQUtils.clamp(math.exp(
            unhappyRate * (data.totalDaysNotBrushed - gracePeriod) /
            (tonumber(data.totalDaysNotBrushed >= (newMax / 2)) + 1)),
        0,
        unhappyMax)
    local stressFormula = AQUtils.clamp(math.exp(
            stressRate * (data.totalDaysNotBrushed - gracePeriod) /
            (tonumber(data.totalDaysNotBrushed >= (newMax / 2)) + 1)),
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

function AQEvents.register()
    Events.OnGameBoot.Add(AQEvents.OnGameBoot)
    Events.OnInitGlobalModData.Add(AQEvents.OnInitGlobalModData)
    Events.OnCreatePlayer.Add(AQEvents.OnCreatePlayer)
    Events.OnPlayerDeath.Add(AQEvents.OnPlayerDeath)
    Events.OnFillWorldObjectContextMenu.Add(AQWorldObjectContextMenu.createMenu)
    Events.EveryTenMinutes.Add(AQEvents.EveryTenMinutes)
    Events.EveryDays.Add(AQEvents.EveryDays)
end

return AQEvents
